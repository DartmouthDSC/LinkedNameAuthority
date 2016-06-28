require 'uri'
require 'faraday'

module Symplectic
  module Elements
    class ApiError < StandardError; end # Request returns, but an error message is present.
    class RequestError < StandardError; end # Params for request invalid.
    
    class Api < ::Faraday::Connection

      attr_reader :config
      
      # Creates connection to Elements API connection with basic authentication information.
      def initialize
        load_config        
        super(url: self.config[:api_root])
        self.basic_auth(self.config[:username], self.config[:password])
      end

      def self.config
        Rails.application.config_for(:elements).symbolize_keys
      end
      
      private
      
      # Load configuration from yaml file containing api_root, username and password for each
      # environment.
      #
      # Note: Rails is being used to load the configuration, if this library is moved out into
      # its own gem this part of the code will have to be rewritten to remove the dependency on
      # rails.
      #
      # @example Configuration Yaml File
      #   development:
      #     user: example
      #     password: secret
      #     api_root: https://example.com/api
      #
      def load_config
        c = Symplectic::Elements::Api.config

        # Assure the keys we need are present.
        [:password, :username, :api_root].each do |k|
          unless c.key?(k) && !c[k].blank?
            raise "elements.yml missing #{k} for #{Rails.env}"
          end
        end

        @config = c
      end
    end
  end
end
