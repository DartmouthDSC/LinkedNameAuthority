require 'rdf'
module Vocabs
  class OwlTime < RDF::Vocabulary('http://www.w3.org/2006/time#')
    property :hasBeginning
    property :hasEnd
  end
end
