require 'rdf'
module Vocabs
  class LNA < RDF::Vocabulary('http://dac.dartmouth.edu/ontologies/lna#')
    property :historicPlacement
    property :responsibleFor
  end
end
