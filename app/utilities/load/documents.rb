require 'symplectic/elements/users'

module Load
  class Documents < Loader
    ELEMENTS_IMPORT_TITLE = 'Documents from Elements'

    # Keys for warnings hash.
    NEW_DOCUMENTS = 'new document'
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
      # Get the last import.
      i = Import.where(load: ELEMENTS_IMPORT_TITLE).order(time_started: :asc).first
      last_import = (i) ? i.time_started : nil
      # puts last_import.class.name # is Time, will throw errors in very near future.

      batch_load(title: ELEMENTS_IMPORT_TITLE, verbose: true, throw_errors: false) do |load|
        begin
          users = Symplectic::Elements::Users.get_all(modified_since: last_import)
        rescue Exception => e
          load.add_to_errors(e.message, 'while retrieving users.')
          (load.throw_errors) ? raise : break
        end
                       
        users.each do |user|
          begin
            puts user.proprietary_id
            publications = user.publications(modified_since: last_import)
          rescue StandardError => e
            load.add_to_errors(e.message, user.proprietary_id)
            (load.throw_errors) ? raise : next
          ensure
            next unless publications # If there aren't any modified publications, skip.
          end
          
          publications.each do |publication|
            begin
              doc_hash = publication.to_hash
              doc_hash[:elements_id] = doc_hash.delete(:id)
              
              hash = {
                netid: user.proprietary_id,
                document: doc_hash
              }

              load.into_lna(hash)
            rescue StandardError => e
              load.add_to_errors(e.message,
                            "Elements document #{publication.id} for #{user.proprietary_id}")
              (load.throw_errors) ? raise : next
            end
          end
        end
        puts load.errors
        byebug
      end
    end
    
    # Creates Lna object for the document describe by the given hash
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
    def into_lna(hash = {})
      # Check if user currently exists.
      acnts = Lna::Account.where(title: Lna::Account::DART_PROPERTIES[:title],
                                 account_name: hash[:netid])
      
      if acnts.count.zero?  # Could not find Person.
        add_to_warnings(PERSON_RECORD_NOT_FOUND, hash[:netid])
        return
      elsif acnts.count > 1
        raise "More than one account for #{hash[:netid]}" 
      end

      collection = acnts.first.account_holder.collections.first

      # If there's an elements id, check to see if there's already a document with that id.
      # If there is, don't add it again.
      if e_id = hash[:document][:elements_id]
        if Lna::Collection::Document.where(elements_id: e_id).count > 0
          return
        end
      end

      Lna::Collection::Document.create!(hash[:document]) do |doc|
        doc.collection = collection
      end
      add_to_warnings(NEW_DOCUMENT, "for #{hash[:netid]} with the title #{hash[:title]}")
    end
  end
end
