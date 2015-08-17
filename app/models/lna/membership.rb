module Lna
  class Membership < ActiveFedora::Base
    belongs_to :person, class_name: 'Lna::Person',
               predicate: ::RDF::Vocab::ORG.hasMember
    belongs_to :organization, class_name: 'Lna::Organization',
               predicate: ::RDF::Vocab::ORG.Organization
    
    #validates_presence_of :person, :organization, :title, :member_during
    validates_presence_of :person, :organization, :title
    
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
    
    property :member_during, predicate: ::RDF::Vocab::ORG.memberDuring, multiple: false do |index|
      index.as :displayable
    end
  end
end
