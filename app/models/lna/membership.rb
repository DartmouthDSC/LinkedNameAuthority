require 'owl_time'

module Lna
  class Membership < ActiveFedora::Base
    include Lna::DateHelper
    
    belongs_to :person, class_name: 'Lna::Person',
               predicate: ::RDF::Vocab::ORG.hasMember
    belongs_to :organization, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.Organization

    validates_presence_of :person, :organization, :title, :begin_date
    
    validates :organization,
              type: { valid_types: [Lna::Organization, Lna::Organization::Historic] }

    validates :end_date, date: { on_or_after: :begin_date }, if: :ended?
    
    property :title, predicate: ::RDF::Vocab::VCARD.title, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :email, predicate: ::RDF::Vocab::VCARD.email, multiple: false do |index|
      index.as :displayable
    end
    
    property :street_address, predicate: ::RDF::Vocab::VCARD['street-address'],
             multiple: false do |index|
      index.as :displayable
    end
    
    property :pobox, predicate: ::RDF::Vocab::VCARD['post-office-box'], multiple: false do |index|
      index.as :displayable
    end
    
    property :locality, predicate: ::RDF::Vocab::VCARD.locality, multiple: false do |index|
      index.as :displayable
    end
  
    property :postal_code, predicate: ::RDF::Vocab::VCARD['postal-code'], multiple: false do |index|
      index.as :displayable
    end
    
    property :country_name, predicate: ::RDF::Vocab::VCARD['country-name'],
           multiple: false do |index|
      index.as :displayable
    end
    
    property :begin_date, predicate: Vocabs::OwlTime.hasBeginning, multiple: false do |index|
      index.type :date
      index.as :stored_searchable
    end

    property :end_date, predicate: Vocabs::OwlTime.hasEnd, multiple: false do |index|
      index.type :date
      index.as :stored_searchable
    end

    def begin_date=(d)
      date_setter('begin_date', d)
    end

    def end_date=(d)
      date_setter('end_date', d)
    end

    def ended?
      end_date != nil
    end

    def active?
      end_date == nil
    end
  end
end
