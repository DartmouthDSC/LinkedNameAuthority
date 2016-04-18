# Wrapper around Active Fedora Solr helpers. This class contains specific queries for use in the
# Lna. Controllers that include this module should also implement a not_found method. When a
# resource is not found, the not_found method is called.
module SolrSearchBehavior
  extend ActiveSupport::Concern

  DEFAULT_MAX_ROWS = 100000.freeze
  
  # Hits Solr API with parameters given. Returns an array of results. This method allows the
  # most flexibility because all parameters can be used (or ommited).
  #
  # @param params [Hash] parameters to be given to Solr API
  # @param only_one [Boolean] flag to limit results to only one
  # @return [Hash, RSolr::Response::PaginatedDocSet] document(s) returned by search
  def solr_search(params, only_one = false)
    raise 'only_one flag cannot be used in cujunction with raw param' if params[:raw] && only_one
    
    logger.debug("Solr params: #{params.to_s}")
    results = ActiveFedora::SolrService.query(params[:q], params)

    if only_one && results.count == 1
      results.first
    elsif only_one
      not_found
    else
      results
    end
  end

  # Search Solr for an id. Returns only one result, will throw errors if there is no response
  # or more than one response.
  #
  # @param id [String] full fedora id used for lookup
  def search_for_id!(id)
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids([id])
    results = ActiveFedora::SolrService.query(query)

    case results.count
    when 1
      results.first
    when 0
      raise_error 'No results for the id given.'
    else
      raise_error 'More than one result for the id given.'
    end
  end

  # Searches Solr for an id, if there isn't only one result the not_found method is called.
  # Controllers that use this methods/module should have a not_found method implemented.
  #
  # @param (see #search_for_id!)
  def search_for_id(id)
    begin
      search_for_id!(id)
    rescue
      not_found
    end
  end

  # Search for a list of ids.
  #
  # @param ids [Array<String>] list of full fedora ids
  def search_for_ids(ids)
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(ids)
    logger.debug("Solr ids query: #{query}")
    results = ActiveFedora::SolrService.query(query, rows: DEFAULT_MAX_ROWS)
    logger.debug(results.inspect)
    results
  end
  
  # Searches Solr for a Lna::Person with the given id.
  # If an id is given, and there are no results the not_found method is called.
  #
  # @param (see #search_with_model_filter)
  # if a query is given it will override the id query
  def search_for_persons(id: nil, q: nil, **args)
    q = (id) ? [['id', id]] : q
    search_with_model_filter(Lna::Person, q: q, only_one: id != nil, **args)
  end
  
  # Search for account(s). If id is given only one result is returned. If only a person_id
  # is given then all the accounts for that person are returned.
  #
  # @param id [String]
  # @param account_holder_id [String]
  # @param orcid [Boolean]
  def search_for_accounts(id: nil, account_holder_id: nil, orcid: false, **args)
    q = []
    q << ['account_ssim', account_holder_id] if account_holder_id
    q << ['id', id] if id
    q << ['title_tesi', 'ORCID'] if orcid

    only_one = orcid || ( id != nil )
    search_with_model_filter(Lna::Account, q: q, only_one: only_one, **args)
  end

  # Searches for an account of the person given that has a "ORCID" as its title.
  #
  # @param account_holder_id [String] full fedora id of the person
  # @return
  def search_for_orcid(person_id)
    search_for_accounts(account_holder_id: person_id, orcid: true)
  end

  # Search for a memberships based on id and/or person_id.
  # 
  # @param id [String]
  # @param person_id [String]
  def search_for_memberships(id: nil, person_id: nil, **args)
    q = []
    q << [ 'hasMember_ssim', person_id ] if person_id
    q << [ 'id', id ] if id
    
    search_with_model_filter(Lna::Membership, q: q, only_one: id != nil, **args)
  end

  # Search for a works based on id, collection id, start_date or any combination.
  # 
  #
  # if query is given id and collection id are ignored.
  def search_for_works(id: nil, collection_id: nil, start_date: nil, q: nil, **args)
    raise ':q cannot be used in conjunction with :id or :collection_id' if (id || collection_id) && q
    if q == nil
      q = []
      q << ['id', id] if id
      q << ['isPartOf_ssim', collection_id] if collection_id
    end
    
    if start_date
      date = Date.parse(start_date.to_s).strftime('%FT%TZ')
      q = ActiveFedora::SolrQueryBuilder.construct_query(q) if q.is_a? Array
      q << " AND" unless q.blank?
      q << " date_dtsi:[#{date} TO *]"
    end
    
    search_with_model_filter(Lna::Collection::Document, q: q, only_one: id != nil, **args)
  end

  def search_for_licenses(id: nil, document_id: nil, **args)
    q = []
    q << ['id', id] if id
    q << ['license_ref_ssim', document_id] if document_id

    search_with_model_filter([Lna::Collection::FreeToRead, Lna::Collection::LicenseReference],
                             q: q, only_one: id != nil, **args)
  end

  # Search for active organization only.
  #
  # @param parents [Boolean] if true returns parent organizations
  def search_for_active_organizations(**args)
    search_for_organizations(historic: false, **args)
  end

  # Searches through both historic and active organizations. If an id is given only one
  # result is returned.
  #
  # @param historic [Boolean] if true includes historic organizations otherwise doesn't
  def search_for_organizations(id: nil, historic: true, q: nil, **args)
    raise ArgumentError, ':id parameter cannot be used in conjunction with :q' if id && q
    
    models = [Lna::Organization]
    models << Lna::Organization::Historic if historic

    q = [['id', id]] if id
    
    search_with_model_filter(models, q: q, only_one: id != nil, **args)
  end
  
  # Search solr with a model filter. This method allows for many solr parameters that are passed
  # on to solr with the query. Based on rows and page, the start parameter is calculated. If query
  # is array it assumes its a array of array of field pairs, otherwise it passes the q parameter
  # as is.
  #
  # @param model [Class, Array<Class>] model to be filtered by
  # @param q [String, Array] query to be passed to solr, if an array it gets convered to a string.
  # @param only_one [Boolean] if true only one search result should be returned
  # @param rows [Integer, nil] max number of results to be returned by solr, default is set
  #   to 100000
  # @param sort [String, nil]  sort solr parameter 
  # @param page [Integer, nil] page of results to be displayed.
  def search_with_model_filter(model, q: nil, only_one: false, rows: DEFAULT_MAX_ROWS, sort: nil,
                               page: nil, **args)
    raise ArgumentError, 'Cannot calculate start param without rows.' if page && !rows
    
    q = '*:*' if q.blank?
    q = ActiveFedora::SolrQueryBuilder.construct_query(q) if q.is_a? Array
    
    args[:fq] = model_filter(model)
    args[:q] = q
    args[:rows] = rows if rows
    args[:sort] = sort if sort
    args[:start] = (rows * (page - 1)) + 1 if (rows && page && page > 1)
    
    solr_search(args, only_one)
  end

  private

  # Generates model filter string to be used as the :fq solr parameter.
  #
  # @private
  #
  # @param class_name [Class, Array<Class>] class or array of classes to filter by
  # @return [String] string to be used for :fq solr parameter
  def model_filter(class_name)
    class_name = [class_name] unless class_name.is_a? Array
    class_name.map { |c| "has_model_ssim:\"#{c.to_s}\"" }.join(' ')
  end

  # 
  #
  # @private
  #
  # @param field_array [Array<Array<String, String>>]
  # @param join_with [String]
  # @return [String] 
  # def field_query(field_array, join_with = " AND ")
  #   field_array.map { |i| "#{i[0]}:#{solr_escape(i[1])}" }.join(join_with)
  # end
  # def field_query(*args)
  #   ActiveFedora::SolrQueryBuilder.construct_query(*args)
  # end

  # Method taken from ActiveFedora::SolrQueryBuilder.
  #
  # @private
  #
  def solr_escape(terms)
    RSolr.solr_escape(terms).gsub(/\s+/, "\\ ")
  end

  # Create query using field parser. Equivalent to Lucene's field:"value" query.
  # Inspired from ActiveFedora::SolrQueryBuilder.field_query.
  def field_query(field, value)
    "_query_:\"{!field f=#{field}}#{value}\""
  end
  
  # Create query using complexphrase parser. This allows users to search with wildcard (*) and
  # fuzzy (~) special characters.
  def complexphrase_query(field, phrase)
    return unless phrase
    # if phrase is an empty string phrase should equal '""'
    # currently, throws errors if string is empty
    phrase = "\\\"#{phrase}\\\"" if phrase.match(/\s/)
    "_query_:\"{!complexphrase inOrder=false}#{field}:#{phrase}\""
  end

  # Create query using join parser, similar to sql join.
  def join_query(from, to, field, value)
    "_query_:\"{!join from=#{from} to=#{to}}#{field}:\\\"#{value}\\\"\""
  end
end
