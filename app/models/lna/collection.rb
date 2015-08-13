class Lna::Collection < ActiveFedora::Base
  has_many :documents, class_name: 'Lna::Collection::Document',
           predicate: ::RDF::DC.hasPart, dependent: :destroy

  # Probably needs a better predicate.
  belongs_to :person, class_name: 'Lna::Person',
             predicate: ::RDF::FOAF.publications 

  validates_presence_of :person
end
