require 'rdf'
module Vocabs
  class LNA < RDF::Vocabulary('http://dac.dartmouth.edu/ontologies/lna#')
    property :historicPlacement
    property :responsibleFor
    property :elementsId,
             label: 'elementsID',
             range: 'rdfs:Literal'.freeze,
             subPropertyOf: 'bibo:identifier'.freeze,
             type: 'owl:DatatypeProperty'.freeze
    
  end
end
