module Lna
  class Organization
    class ChangeEvent < ActiveFedora::Base
      has_many :resulting_organizations, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.resultingOrganization,
               as: 'resulted_from'
      has_many :original_organizations, class_name: 'Lna::Organization::Historic',
               predicate: ::RDF::Vocab::ORG.originalOrganization,
               as: 'changed_by'
      
      validate :max_one_original_org

      # Resulting organization must be a Lna::Organization or Lna::Organization::Historic
      validates :resulting_organizations,
               type: { valid_types: [Lna::Organization, Lna::Organization::Historic] }
                                                                    
      validates_presence_of :resulting_organizations, :original_organizations,
                            :at_time, :description
  
      property :at_time, predicate: ::RDF::PROV.atTime, multiple: false do |index|
        index.as :displayable
      end
      
      property :description, predicate: ::RDF::DC.description, multiple: false do |index|
        index.as :displayable
      end
      
      def max_one_original_org
        if original_organizations.size > 1
          errors.add(:original_organizations, 'can\'t have more than 1 organization.')
        end
      end
    end
  end
end
