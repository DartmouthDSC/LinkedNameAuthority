require 'lna/field_mapper'
Solrizer.default_field_mapper = Lna::FieldMapper.new

# Overriding PARSED_SUFFIX constant in ActiveFedora because :stored_searchable was overriden to
# be a single valued field. PARSED_SUFFIX updated to reflect the change made to :stored_searchable.
module ActiveFedora
  module SolrQueryBuilder
    remove_const(:PARSED_SUFFIX) if (defined?(PARSED_SUFFIX))
    PARSED_SUFFIX = '_tesi'.freeze
  end
end
