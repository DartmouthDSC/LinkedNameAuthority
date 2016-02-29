require 'owl_time'
require 'lna_terms'

module Lna
  class Organization
    class Historic < ActiveFedora::Base
      include Lna::OrganizationCoreBehavior
      
      belongs_to :changed_by, class_name: 'Lna::Organization::ChangeEvent',
                 predicate: ::RDF::Vocab::ORG.changedBy

      validates_presence_of :end_date
      
      # Serialization of sub and super organizations.
      property :historic_placement, multiple: false, predicate: Vocabs::LNA.historicPlacement do |index|
        index.as :displayable
      end

      property :end_date, predicate: Vocabs::OwlTime.hasEnd, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end

      def end_date=(d)
        date_setter('end_date', d)
      end
    end
  end
end
