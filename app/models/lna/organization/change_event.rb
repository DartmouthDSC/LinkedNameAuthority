module Lna
  class Organization
    class ChangeEvent < ActiveFedora::Base
      include Lna::DateHelper
      
      has_many :resulting_organizations, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.resultedFrom
      has_many :original_organizations, class_name: 'Lna::Organization::Historic',
               inverse_of: :changed_by, as: :changed_by
      
      validates :original_organizations, length_is_one: true

      validates_presence_of :resulting_organizations, :original_organizations,
                            :at_time, :description
  
      property :at_time, predicate: ::RDF::PROV.atTime, multiple: false do |index|
        index.type :date
        index.as :displayable
      end
      
      property :description, predicate: ::RDF::DC.description, multiple: false do |index|
        index.as :displayable
      end
      
      def at_time=(d)
        date_setter('at_time', d)
      end
    end
  end
end
