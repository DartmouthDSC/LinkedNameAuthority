module Load
  class Loader
    attr_reader :errors, :warnings, :time_started, :title
    attr_accessor :verbose, :throw_errors, :emails

    # Initializer for all classes that are batch loading records into the LNA.
    #
    # @param title [String]
    # @param verbose [Boolean]
    # @param throw_errors [Boolean] flag to throw errors after logging them
    # @param emails [Array<String>|String] array of emails or string containing one email
    def initialize(title:, verbose: true, throw_errors: true, emails: nil)
      @title = title
      @verbose = verbose
      @throw_errors = throw_errors
      @emails = emails.is_a?(String) ? [emails] : emails
      @errors = {}
      @warnings = {}
      @time_started = Time.now
    end

    # Creates a new loader and runs the block given. Used to load a set of records. At the
    # end of executing the block given the load in logged in the Import table. Without a block
    # this method virtually does nothing.
    #
    def self.batch_load(**args)
      loader = new(**args)
      if block_given?
        begin
          return yield(loader)
        ensure
          loader.log_load
        end
      end
    end

    # Logs load by adding a row to the Import table with basic details about the load. Subclasses
    # should override this method and call super with a status parameter to provide details
    # about the load.
    #
    # @param status [String|nil] details about load
    def log_load(status: nil)
      status = warnings.map { |k, v| [v.count, k].join(' ') } if warnings
      status << "#{errors.count} errors" if errors
      
      Import.create! do |i|
        i.load = title
        i.time_started = time_started
        i.time_ended = Time.now
        i.status = status.join(', ') if status
      end
    end

    def add_to_warnings(k, v)
      add_to_hash(@warnings, k, v)
    end
    
    def add_to_errors(k, v)
      add_to_hash(@errors, k, v)
    end
    
    private

    def add_to_hash(hash, k, v)
      hash.key?(k) ? hash[k] << v : hash[k] = [v]
    end
  end
end
