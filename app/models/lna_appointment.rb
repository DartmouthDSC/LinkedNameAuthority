class LnaAppointment < ActiveFedora::Base
  belongs_to :LnaPerson
  
  property :title, predicate: ::RDF::VCARD.title, multiple: false
  property :email, predicate: ::RDF::VCARD.email, multiple: false
  property :org, predicate: ::RDF::VCARD.org, multiple: false
  property :street_address, predicate: ::RDF::VCARD.street-address, multiple: false
  property :pobox, predicate: ::RDF::VCARD.pobox, multiple: false
  property :locality, predicate: ::RDF::VCARD.locality, multiple: false
  property :postal_code, predicate: ::RDF::VCARD.postal-code, multiple: false
  property :country_name, predicate: ::RDF::VCARD.country-name, multiple: false
  property :has_beginning, predicate: ::RDF::XSD.dateTimeStamp, multiple: false
  property :has_end, predicate: ::RDF::XSD.dateTimeStamp, multiple: false
end
