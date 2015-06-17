class LnaAppointment < ActiveFedora::Base
  belongs_to :lna_person,
             predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isDependentOf

  validates_presence_of :vcard_title, :vcard_org, :time_has_beginning
  
  owltime = ::RDF::Vocabulary.new('http://www.w3.org/2006/time/')
  
  property :vcard_title, predicate: ::RDF::VCARD.title, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :vcard_email, predicate: ::RDF::VCARD.email, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :vcard_org, predicate: ::RDF::VCARD.org, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :vcard_street_address, predicate: ::RDF::VCARD['street-address'],
           multiple: false do |index|
    index.as :displayable
  end
  
  property :vcard_pobox, predicate: ::RDF::VCARD['post-office-box'], multiple: false do |index|
    index.as :displayable
  end
  
  property :vcard_locality, predicate: ::RDF::VCARD.locality, multiple: false do |index|
    index.as :displayable
  end
  
  property :vcard_postal_code, predicate: ::RDF::VCARD['postal-code'], multiple: false do |index|
    index.as :displayable
  end
  
  property :vcard_country_name, predicate: ::RDF::VCARD['country-name'],
           multiple: false do |index|
    index.as :displayable
  end
  
  property :time_has_beginning, predicate: owltime.hasBeginning, multiple: false do |index|
    index.as :dateable
  end
  
  property :time_has_end, predicate: owltime.hasEnd, multiple: false do |index|
    index.as :dateable
  end

end
