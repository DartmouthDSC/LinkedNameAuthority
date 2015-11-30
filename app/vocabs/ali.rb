require 'rdf'
module Vocabs
  class ALI < RDF::Vocabulary('http://niso.org/schemas/ali/1.0/')
    term :license_ref,
         comment: %(Agreement related to the use of a work. Generally includes payment requirements, if any, and terms of use and re-use-potentially including access, reproduction, adaptation, and
distribution, among others.),
         
    term :free_to_read,
         comment: %(A work that is accessible to read online without charge or authentication (including registration) to any person with access to the internet.),
    
    property :start_date,
             domain: ["ali:free_to_read".freeze, "ali:license_ref".freeze],
             range: "xsd:date".freeze,
             type: "xsd:date".freeze
    
    property :end_date,
             domain: ["ali:free_to_read".freeze, "ali:license_ref".freeze],             
             range: "xsd:date".freeze,
             type: "xsd:date".freeze
    
    property :uri,
             domain: "ali:license_ref".freeze,
             type: "xsd:anyURI".freeze
  end
end
