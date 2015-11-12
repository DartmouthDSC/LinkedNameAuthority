require 'owl_time'
module Lna
  module OrganizationCoreBehavior
    extend ActiveSupport::Concern
    include Lna::DateHelper
    
    included do
      has_many :people, class_name: 'Lna::Person', dependent: :restrict,
               inverse_of: :primary_org, as: :primary_org
      has_many :memberships, class_name: 'Lna::Membership', dependent: :destroy,
               inverse_of: :organization

      belongs_to :resulted_from, class_name: 'Lna::Organization::ChangeEvent',
                 predicate: ::RDF::Vocab::ORG.resultedFrom

      validates_presence_of :label, :begin_date

      type ::RDF::Vocab::ORG.Organization

      property :label, predicate: ::RDF::Vocab::SKOS.prefLabel, multiple: false do |index|
        index.as :stored_searchable
      end

      property :alt_label, predicate: ::RDF::Vocab::SKOS.altLabel do |index|
        index.as :multiple_stored_searchable
      end

      property :code, predicate: ::RDF::Vocab::ORG.identifier, multiple: false do |index|
        index.as :stored_searchable
      end

      property :begin_date, predicate: Vocabs::OwlTime.hasBeginning, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end

      def begin_date=(d)
        date_setter('begin_date', d)
      end
    end
  end
end
