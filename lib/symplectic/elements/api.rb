require 'uri'

module Symplectic
  module Elements
    class Api < Faraday::Connection
      
      API_ROOT = 'https://elements-api-dev.dartmouth.edu:9002/elements-secure-api/'

      # Creates connection to Elements API with basic authentication information.
      def initialize
        super(url: API_ROOT)
        
        raise 'Elements username not set' unless ENV['ELEMENTS_USERNAME']
        raise 'Elements password not set' unless ENV['ELEMENTS_PASSWORD']
        
        self.basic_auth(ENV['ELEMENTS_USERNAME'], ENV['ELEMENTS_PASSWORD'])
        # read in options (api root, login, pass) from elements.yml ????
      end
    end
  end
end
