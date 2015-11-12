require 'lna/descriptors'
module Lna
  class FieldMapper < Solrizer::FieldMapper
    self.descriptors = [Lna::Descriptors]
  end
end
