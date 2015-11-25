require 'rdf'
1;95;0cmodule Vocabs
  class ALI < RDF::Vocabulary('http://niso.org/schemas/ali/1.0/')
    term :license_ref,
         comment: %(Agreement related to the use of a work. Generally includes payment requirements, if any, and terms of use and re-use-potentially including access, reproduction, adaptation, and
distribution, among others.),
    
    term :free_to_read,
         comment: %(A work that is accessible to read online without charge or authentication (including registration) to any person with access to the internet.),
         domain: "xsd:boolean".freeze
    
    property :start_date,
             domain: ["ali:free_to_read".freeze, "ali:license_ref".freeze],
             range: "xsd:date".freeze
    
    property :end_date,
             domain: ["ali:free_to_read".freeze, "ali:license_ref".freeze],             
             range: "xsd:date".freeze
    
    property :uri,
             comment: %(A string of characters used to identify the name of a resource. Such identification enables interaction with representations of the resource over the web. The most common form of a URI is the uniform resource locator (URL), frequently referred to informally as a web address.),
             domain: "ali:free_to_read".freeze
  end
end
