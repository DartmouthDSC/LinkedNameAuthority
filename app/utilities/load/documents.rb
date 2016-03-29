require 'symplectic/elements/users'

module Load
  class Documents < Loader
    ELEMENTS_LOADER = 'Documents from Elements'

    # Keys for warnings hash.
    NEW_DOCUMENT = 'new document'
    PERSON_RECORD_NOT_FOUND = 'person records not found'
    
    # Import latest newly created publication records from Elements. If a document is already
    # present in the LNA, it is NOT updated.
    #
    # Overview of Steps:
    #   1. Query for all users that have been modified since the last time the import was done.
    #   2. Iterate through all the users for publications that have been modified since the last
    #      time the import was done.
    #      a. If no publications have been updated continue to the next user
    #      b. Otherwise, retrive the Lna::Person object for this person (if there is one).
    #          1. For each publication check if there is already a Lna::Collection::Document
    #             object.
    #          2. If there isn't a publication record create a new record and attach it to the
    #             user, otherwise continue to the next publication.
    def self.from_elements
      batch_load(ELEMENTS_LOADER) do |load|
        begin
          # Get the last import.
          i = Import.last_successful_import(load.title)
#          i = Import.where(load: ELEMENTS_LOADER,
#                           success: true).order(time_started: :asc).first
          last_import = (i) ? i.time_started : nil
          
          users = Symplectic::Elements::Users.get_all(modified_since: last_import)
        rescue StandardError => e
          load.log_error(e, 'while retrieving users.')
          raise e if throw_errors
          break
        end
                       
        users.each do |user|
          begin
            publications = user.publications(modified_since: last_import)
          rescue StandardError => e
            id = (user.proprietary_id) ?
                   "Proprietary id: #{user.proprietary_id}" : "Elements id: #{user.id}"
            load.log_errors(e, id)
            raise e if throw_errors
#            next
          ensure
            next unless publications # If there aren't any modified publications, skip.
          end
          
          publications.each do |publication|
            begin
              doc_hash = publication.to_hash
              doc_hash[:elements_id] = doc_hash.delete(:id)

              # Remove any singleton backslashes in abstracts (only place the problem has
              # been present).
              if abstract = doc_hash[:abstract]
                doc_hash[:abstract] = abstract.gsub('\\', '')
              end
              
              hash = {
                netid: user.proprietary_id,
                document: doc_hash
              }

              load.into_lna(hash)
            rescue StandardError => e
              load.log_error(e,"Elements document #{publication.id} for #{user.proprietary_id}")
              raise e if throw_errors
              next
            end
          end
        end
      end
    end


    # Creates the document described by the given hash. If a netid is given this document is
    # associated with the corresponding person. At this point only ingesting documents by
    # netid is supported.
    #
    # @example Example of hash
    #   lna_hash = { netid: 'd00000k',
    #                document: {
    #                            title: 'The Best Article Ever',
    #                            elements_id: '1234',
    #                            author_list: ['John Doe', 'Jane Doe']
    #                          },
    #              }
    #
    def into_lna(hash)
      if hash[:netid]
        into_lna_by_netid!(hash[:netid], hash[:document])
      else
        raise NotImplementedError, 'Can only import document is netid is present.'
      end
    rescue NotImplementedError, ArgumentError => e
      log_error(e, hash.to_s)
      raise e if throw_errors
      return nil
    rescue
      value = (hash[:elements_id]) ?
                "Elements id: #{hash[:elements_id]}" :
                "#{hash[:document][:title]} for #{hash[:netid]}"
      log_error(e, value)
      raise e if throw_errors
      return nil
    end
    
    # Creates the document described and associates it with the corresponding person.
    #
    # @example Example of hash
    #   lna_hash = {
    #                title: 'The Best Article Ever',
    #                elements_id: '1234',
    #                author_list: ['John Doe', 'Jane Doe']
    #              }
    # @param [String] netid person's netid
    # @param [Hash] hash document properties
    def into_lna_by_netid!(netid, hash)
      # Check if user exists.
      unless person = find_person_by_netid(netid)
        log_warning(PERSON_RECORD_NOT_FOUND, netid)
        return
      end

      collection = person.collections.first

      # If there's an elements id, check to see if there's already a document with that id.
      # If there is, don't add it again.
      return if Lna::Collection::Document.where(elements_id: hash[:elements_id]).count > 0

      d = Lna::Collection::Document.create!(hash) do |doc|
        doc.collection = collection
      end
      
      warning_text = (d.elements_id) ?
                       "elements id #{d.elements_id}" : "title #{d.title}"
      log_warning(NEW_DOCUMENT, "for #{netid} with the #{warning_text}")
    end
  end
end
