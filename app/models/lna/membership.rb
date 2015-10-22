require 'owl_time'

module Lna
  class Membership < ActiveFedora::Base
    include Lna::DateHelper
    
    belongs_to :person, class_name: 'Lna::Person',
               predicate: ::RDF::Vocab::ORG.hasMember
    belongs_to :organization, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.Organization

    validates :organization,
              type: { valid_types: [Lna::Organization, Lna::Organization::Historic] }
    
    validates_presence_of :person, :organization, :title, :begin_date
    
    property :title, predicate: ::RDF::VCARD.title, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :email, predicate: ::RDF::VCARD.email, multiple: false do |index|
      index.as :displayable
    end
    
    property :street_address, predicate: ::RDF::VCARD['street-address'],
             multiple: false do |index|
      index.as :displayable
    end
    
    property :pobox, predicate: ::RDF::VCARD['post-office-box'], multiple: false do |index|
      index.as :displayable
    end
    
    property :locality, predicate: ::RDF::VCARD.locality, multiple: false do |index|
      index.as :displayable
    end
  
    property :postal_code, predicate: ::RDF::VCARD['postal-code'], multiple: false do |index|
      index.as :displayable
    end
    
    property :country_name, predicate: ::RDF::VCARD['country-name'],
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
