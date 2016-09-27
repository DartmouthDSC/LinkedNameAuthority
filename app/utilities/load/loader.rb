require 'active_fedora/errors'

module Load
  class ObjectNotFoundError < ActiveFedora::ObjectNotFoundError; end
  class Loader
    # Keys for warnings hash.
    SENT_EMAIL = 'sent email'
    
    attr_reader :title, :errors, :warnings, :time_started, :error_notices, :all_notices

    # Initializer for all classes that are batch loading records into the LNA.  Emails are read
    # in from environmental variables. @all_notices email list is populated from
    # ENV['LOADER_NOTICES'], @error_notices email list is populated from
    # ENV['LOADER_ERROR_NOTICES']. This class logs warnings and errors, it also keeps a hash of
    # warnings and errors to email out.
    #
    # @param title [String] name of loader
    def initialize(title)
      @title = title
      @errors = {}
      @warnings = {}
      @time_started = Time.now
      @error_notices = (ENV['LOADER_ERROR_NOTICES']) ? ENV['LOADER_ERROR_NOTICES'].split(',') : []
      @all_notices = (ENV['LOADER_NOTICES']) ? ENV['LOADER_NOTICES'].split(',') : []

      if @error_notices.empty? && @all_notices.empty?
        raise ArgumentError, 'at least one email for error notices is required.'
      end
    end

    # Creates a new loader and runs the block given. Used to load a set of records. At the
    # end of executing the block given the load in logged in the Import table and an email is
    # sent out. Without a block this method does nothing.
    def self.batch_load(title)
      if block_given?
        begin
          loader = new(title)
          yield(loader)
          begin
            loader.send_email
          rescue => e
            loader.log_error(e, "error while sending email")
          end
          loader.add_to_import_table
        rescue => e
          Rails.logger.tagged('LOADER') {
            Rails.logger.error("ERROR: #{e}\n\t#{e.backtrace.join("\n\t")}")
          }
          raise e
        end
      end
    end

    # Adds a row to the Import table with basic details about the load that just completed.
    # This method should only be called once the load is complete. 
    def add_to_import_table
      status = ["#{errors.count} #{'error'.pluralize(errors.count)}"]
      status.concat(warnings.map { |k, v| "#{v.count} #{k}" }) unless warnings.empty?
      
      Import.create! do |i|
        i.load = title
        i.time_started = time_started
        i.time_ended = Time.now
        i.status = status.join(', ')
        i.success = errors.empty?
      end
    end

    # Logs warning and adds it to the warning hash.
    #
    # @param k [String] generalized warnings
    # @param v [String] specifics about warning, netid, name, etc
    def log_warning(k, v)
      Rails.logger.tagged('LOADER') {
        Rails.logger.tagged(title.upcase) {
          Rails.logger.info("#{k} #{v}")
        }
      }
      add_to_hash(@warnings, k, v)
    end

    # Logs error and adds it to the error hash.
    #
    # @param e [Exception] exception object to be logged
    # @param v [String] more specific details about exception
    def log_error(e, v)
      Rails.logger.tagged('LOADER') {
        Rails.logger.tagged(title.upcase) {
          message = "ERROR: #{e}"
          message << "\n\t#{e.backtrace.join("\n\t")}" if e.backtrace
          Rails.logger.error(message)
        }
      }
      add_to_hash(@errors, e.message.to_s, v)
    end

    # Send emails notifying recipient of warnings and errors. If there are no errors, warnings
    # are sent to the @all_notices emails list. If there are errors, warnings and errors
    # are sent to the emails listed in @all_notices and @error_notices.
    def send_email
      emails = @all_notices
      emails = emails.concat(@error_notices).uniq unless @errors.empty?

      LoaderMailer.output_email(title, emails, output).deliver_now
      log_warning(SENT_EMAIL, "to #{emails.join(', ')} on #{Time.now.strftime('%c')}")
    end

    # Combine errors and warnings hash into one.
    def output
      { 'error' => @errors, 'warning' => @warnings }
    end
    
    private

    def add_to_hash(hash, k, v)
      hash.key?(k) ? hash[k] << v : hash[k] = [v]
    end

    # Find organization based on hash given. Makes sure that the organization fields match when
    # compared. Will throw errors if multiple organizations are found. Prioritizes finding
    # active organizations. If no active organization if found, then historical organization
    # are queried.
    #
    # @example Usage
    #   org = { label: 'Library', code: 'LIB', super_organization_id: 'org_1' }
    #   find_organization(org)
    #
    # @private
    #
    # @param (see #find_organization!)
    # @return [Lna::Organization|Lna::Organization::Historic] if one organization is found
    # @return [ArgumentError] if more than one organization is found
    # @return [nil] if no organization is found
    def find_organization(hash)
      # If hash is empty it will return all the orgs.
      raise ArgumentError, 'Hash cannot be empty.' if hash.empty?

      # Remove super organization and any nil values. Doing a lookup with nil values will
      # return unexpected results.
      hash.compact!
      search_hash = hash.except(:super_organization_id)

      raise ArgumentError, 'Hash cannot only contain super org id' if search_hash.empty?

      begin
        orgs = Lna::Organization.where(search_hash)
        orgs = Lna::Organization::Historic.where(search_hash) if orgs.count.zero?
      rescue RSolr::Error::Http => e
       raise ArgumentError, "Organization look up failed. Invalid key in #{search_hash}"
      end

###   Debug logging...
      Rails.logger.tagged('Lna::Organization/orgs') {####
        Rails.logger.debug("orgs = #{orgs.values}")####
      }####

      # Try to find an exact match, because self.where uses solr to search and solr will return
      # a document if any part of the field matches. Alt_labels are treated a bit differently,
      # all the alt labels given by the hash should be included in the object's alt_label array,
      # but the arrays may not be exact. Super organization ids are only compared if the
      # organization is active.
      orgs = orgs.select do |org|
###     Debug logging...
        Rails.logger.tagged('Lna::Organization/org') {####
          Rails.logger.debug("hash = #{hash}")####
          Rails.logger.debug("org  = #{org.values}")####
        }####
        hash.all? do |k, v|
          if k == :alt_label
            v.all? { |i| org.alt_label.include? i }
          elsif k == :super_organization_id
            if org.active?
              org.super_organization_ids.include? v
            else
              true
            end
          else
            v = Date.parse(v) if [:begin_date, :end_date].include? k
            org.send(k) == v
          end
        end
      end

      case orgs.count
      when 1
        orgs.first
      when 0
        nil
      else
        raise ArgumentError, "more than one organization with the values #{hash.to_s} was found"
      end
    end

    # Finds organization based on hash given. Will throw an error if exactly one organization
    # is not found.
    #
    # @private
    #
    # @param hash [Hash] information used to look up organization
    # @return [Lna::Organization|Lna::Organization::Historic] if one organization is found
    # @return [ArgumentError] if exactly one organization is not found.
    def find_organization!(hash)
      unless result = find_organization(hash)
        raise ObjectNotFoundError, "organization with the values #{hash.to_s} could not be found"
      end
      result
    end

    # Find person with the matching netid.
    #
    # @private
    # 
    # @param netid [String] netid to lookup
    # @return [nil] if no matching person was found
    # @return [Lna::Person] if one matching person was found
    def find_person_by_netid(netid)
      if account = find_dart_account(netid)
        acnt_holder = account.account_holder
        raise "Netid is associated with a #{acnt_holder.class}." unless acnt_holder.is_a?(Lna::Person)
        acnt_holder
      else
        nil
      end
    end

    # Find dartmouth account with the matching netid.
    #
    # @param netid [String] netid to lookup
    # @return [nil] if no matching account was found
    # @return [Lna::Account] if one matching account was found
    def find_dart_account(netid)
      hash = dart_account_hash(netid)
      accounts = Lna::Account.where(hash)

      case accounts.count
      when 0
        nil
      when 1
        accounts.first
      else
        raise ArgumentError, "More than one account for #{netid}."
      end
    end

    def dart_account_hash(netid)
      { account_name: netid }.merge(Lna::Account::DART_PROPERTIES)
    end
  end
end
