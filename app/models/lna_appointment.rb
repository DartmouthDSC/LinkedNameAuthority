class LnaAppointment < ActiveFedora::Base
  belongs_to :lna_person,
             predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  owltime = ::RDF::Vocabulary.new('http://www.w3.org/2006/time/')
  
  property :vcard_title, predicate: ::RDF::VCARD.title, multiple: false
  property :vcard_email, predicate: ::RDF::VCARD.email, multiple: false
  property :vcard_org, predicate: ::RDF::VCARD.org, multiple: false
  property :vcard_street_address, predicate: ::RDF::VCARD['street-address'],
           multiple: false
  property :vcard_pobox, predicate: ::RDF::VCARD['post-office-box'], multiple: false
  property :vcard_locality, predicate: ::RDF::VCARD.locality, multiple: false
  property :vcard_postal_code, predicate: ::RDF::VCARD['postal-code'], multiple: false
  property :vcard_country_name, predicate: ::RDF::VCARD['country-name'],
     multiple: false
  
  property :time_has_beginning, predicate: owltime.hasBeginning, multiple: false
  property :time_has_end, predicate: owltime.hasEnd, multiple: false
end
