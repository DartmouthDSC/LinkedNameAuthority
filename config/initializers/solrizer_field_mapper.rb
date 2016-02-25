require 'lna/field_mapper'

Solrizer.default_field_mapper = Lna::FieldMapper.new

ActiveFedora::SolrQueryBuilder::PARSED_SUFFIX = '_tesi'.freeze
