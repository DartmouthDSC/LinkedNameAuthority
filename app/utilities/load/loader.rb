module Load
  class Loader
    # Keys for warnings hash.
    SENT_EMAIL = 'sent email'
    
    attr_reader :errors, :warnings, :time_started, :title
    attr_accessor :verbose, :throw_errors, :emails

    # Initializer for all classes that are batch loading records into the LNA.  Emails are read
    # in from environmental variables. @all_notices email list is populated from
    # ENV['LOADER_NOTICES'], @error_notices email list is populated from
    # ENV['LOADER_ERROR_NOTICES']. This class logs warnings and errors, it also keeps a hash of
    # warnings and errors to email out.
    #
    # @param title [String]
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
    # sent out. Without a block this method virtually does nothing.
    def self.batch_load(*args)
      if block_given?
        begin
          loader = new(*args)
          yield(loader)
          begin
            loader.send_email
          rescue StandardError => e
            loader.log_error(e, "error while sending email")
          end
          loader.add_to_import_table
        rescue StandardError => e
          Rails.logger.tagged('LOADER') {
            Rails.logger.error("ERROR: #{e}\n\t#{e.backtrace.join("\n\t")}")
          }
          raise e
        end
      end
    end

    # Adds a row to the Import table with basic details about the load that just completed.
    # this method should only be called once the load is complete. 
    def add_to_import_table
      status = warnings.map { |k, v| [v.count, k].join(' ') } unless warnings.empty?
      status << "#{errors.count} #{'error'.pluralize(errors.count)}"
      
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
    # @params k [String] generalized warnings
    # @params v [String] specifics about warning, netid, name, etc
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
          Rails.logger.error("ERROR: #{e}\n\t#{e.backtrace.join("\n\t")}")
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
      t = Time.now
      log_warning(SENT_EMAIL, "to #{emails.join(', ')} on #{t.strftime('%c')}")
    end

    # Combine errors and warnings hash into one.
    def output
      { 'error' => @errors, 'warning' => @warnings }
    end
    
    private

    def add_to_hash(hash, k, v)
      hash.key?(k) ? hash[k] << v : hash[k] = [v]
    end
  end
end
