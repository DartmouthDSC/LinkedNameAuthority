require 'symplectic/elements/publications'

module Symplectic
  module Elements
    class User
      attr_accessor :id, :proprietary_id

      # Creates object from <api:object> element in xml response.
      #
      # @params [Nokogiri::XML::Element] api_object
      def initialize(api_object)
        attri = api_object.attributes
        @id = attri['id'].value
        if p_id = attri['proprietary-id']
          @proprietary_id = p_id.value
        end
      end
      
      # Return a user's publications. If page is not specified only the results from the first
      # page are returned. Results can be limited by the date they were modified.
      #
      # @param [DateTime] modified_since
      # @param [String] detail
      # @return [Array<Symplectic::Elements::Publication>]
      def publications(modified_since: nil) #page
        Symplectic::Elements::Publications.get(modified_since: modified_since,
                                               netid: self.proprietary_id)
        
      end

      # Returns all of a user's publication. Results can be limited by the date they were modified.
      def all_publications(modified_since: nil)
        Symplectic::Elements::Publications.get_all(modified_since: modified_since,
                                                   netid: self.proprietary_id)
        
      end
      
    end
  end
end
