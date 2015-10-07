module Lna
  class Organization
    class ChangeEvent < ActiveFedora::Base
      include Lna::DateHelper
      
      has_many :resulting_organizations, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.resultedFrom
      has_many :original_organizations, class_name: 'Lna::Organization::Historic',
               inverse_of: :changed_by, as: :changed_by
      
      validate :max_one_original_org

      validates_presence_of :resulting_organizations, :original_organizations,
                            :at_time, :description
  
      property :at_time, predicate: ::RDF::PROV.atTime, multiple: false do |index|
        index.type :date
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

      def at_time=(d)
        date_setter('at_time', d)
      end
    end
  end
end
