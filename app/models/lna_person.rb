class LnaPerson < ActiveFedora::Base

  include Hydra::AccessControls::Permissions
  
  has_many :LnaAppointments, dependent: :destroy
  has_many :LnaAccounts, dependent: :destroy

  property :dc_netid, predicate: ::RDF::DC.identifier, multiple: false
  property :foaf_name, predicate: ::RDF::FOAF.name, multiple: false
  property :foaf_given_name, predicate: ::RDF::FOAF.givenName, multiple: false
  property :foaf_family_name, predicate: ::RDF::FOAF.familyName, multiple: true
  property :foaf_title, predicate: ::RDF::FOAF.title, multiple: true
  property :foaf_image, predicate: ::RDF::FOAF.img, multiple: false
  property :foaf_mbox, predicate: ::RDF::FOAF.mbox, multiple: false
  property :foaf_mbox_sha1sum, predicate: ::RDF::FOAF.mbox_sha1sum, multiple: false
  property :foaf_homepage, predicate: ::RDF::FOAF.homepage, multiple: false
  property :foaf_publications, predicate: ::RDF::FOAF.publications, multiple: false
  property :foaf_workplace_homepage, predicate: ::RDF::FOAF.workplaceHomepage,
           multiple: false
  
end
