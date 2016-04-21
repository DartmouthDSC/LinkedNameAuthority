module SolrQueryHelper
  extend ActiveSupport::Concern

  private

  # Create query using field parser. Equivalent to Lucene's field:"value" query.
  # Inspired from ActiveFedora::SolrQueryBuilder.field_query.
  #
  # @param field [String] solr field
  # @param phrase [String] search phrase
  def field_query(field, value)
    "_query_:\"{!field f=#{field}}#{value}\""
  end
  
  # Creates queries using the lucene parser. This allows users to search with wildcard(*) and
  # fuzzy (~) special characters. Words in phrases are ANDed or ORed depending on the value of
  # operation given.
  #
  # @param field [String] solr field
  # @param phrase [String] search term
  # @param op [String] operation to be used when combining words, can be OR or AND
  def grouping_query(field, phrase, op = 'AND')
    raise 'op must be AND or OR' unless ['AND', 'OR'].include? op

    "_query_:\"{!lucene q.op=#{op}}#{field}:(#{phrase})\""
  end

  # Create query using join parser, similar to sql join.
  def join_query(from, to, field, value)
    "_query_:\"{!join from=#{from} to=#{to}}#{field}:\\\"#{value}\\\"\""
  end
end
