class LnaPerson < ActiveFedora::Base
  has_many :LnaAppointments, dependent: :destroy
  has_many :LnaAccounts, dependent: :destroy
  
  property :netid, predicate: ::RDF::DC.identifier, multiple: false
  property :name, predicate: ::RDF::FOAF.name, multiple: false
  property :given_name, predicate: ::RDF::FOAF.givenName, multiple: false
  property :family_name, predicate: ::RDF::FOAF.familyName, multiple: true
  property :title, predicate: ::RDF::FOAF.title, multiple: true
  property :image, predicate: ::RDF::FOAF.img, multiple: false
  property :mbox, predicate: ::RDF::FOAF.mbox, multiple: false
  property :mbox_sha1sum, predicate: ::RDF::FOAF.mbox_sha1sum, multiple: false
  property :homepage, predicate: ::RDF::FOAF.homepage, multiple: false
  property :publications, predicate: ::RDF::FOAF.publications, multiple: false
  property :workplace_homepage, predicate: ::RDF::FOAF.workplaceHomepage,
           multiple: false
  
end
