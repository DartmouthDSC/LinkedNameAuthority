# Wrapper around Active Fedora Solr helpers. This class contains specific queries for use in the
# Lna. Controllers that include this module should also implement a not_found method. When a
# resource is not found, the not_found method is called.
module SolrSearchBehavior
  extend ActiveSupport::Concern

  DEFAULT_MAX_ROWS = 100000.freeze
  
  # Hits Solr API with parameters given. Returns an array of results or a hash with the entire
  # response. This method allows the most flexibility because all parameters can be used
  # (or ommited). It also provides some two flags to customize the output.
  #
  # @param params [Hash] parameters to be given to Solr API
  # @param only_one [Boolean] flag to limit results to only one
  # @param docs_only [Boolean] flag to send entire response or just documents
  # @return [Hash, RSolr::Response::PaginatedDocSet] document(s) returned by search
  def solr_search(params, only_one = false, docs_only = true)
    result = solr_get(params[:q], params)
    docs = result['response']['docs']

    if only_one && docs.count == 1
      if docs_only
        docs.first
      else
        result['response']['docs'] = result['response']['docs'].first
        result
      end
    elsif only_one
      not_found
    else
      (docs_only) ? docs : result
    end
  end

  # Search Solr for an id. Returns only one result, will throw errors if there is no response
  # or more than one response.
  #
  # @param id [String] full fedora id used for lookup
  def search_for_id!(id)
    result = solr_get(ActiveFedora::SolrQueryBuilder.construct_query_for_ids([id]))
    docs = result['response']['docs']
    
    case docs.count
    when 1
      docs.first
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
    result = solr_get(
      ActiveFedora::SolrQueryBuilder.construct_query_for_ids(ids),
      rows: DEFAULT_MAX_ROWS
    )
    result['response']['docs']
  end
  
  # Searches Solr for a Lna::Person with the given id or query. Cannot pass in both a query and
  # and id. If an id is given, only one result is returned. If there are no results the not_found
  # method is called.
  #
  # @param id [String] id of person searching for
  # @param (see #search_with_model_filter)
  def search_for_persons(id: nil, q: nil, **args)
    raise ':q parameter cannot be used in conjunction with :id' if id && q

    if id
      q = [['id', id]]
      args[:only_one] = true
    end

    args[:q] = q
    
    search_with_model_filter(Lna::Person, **args)
  end
  
  # Search for account(s). If id or orcid is given only one result is returned. If only a person_id
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

    args[:q] = q
    args[:only_one] = orcid || id
    
    search_with_model_filter(Lna::Account, **args)
  end

  # Searches for an account of the person given that has a "ORCID" as its title.
  #
  # @param account_holder_id [String] full fedora id of the person
  # @return
  def search_for_orcid(person_id)
    search_for_accounts(account_holder_id: person_id, orcid: true)
  end

  # Search for a memberships based on id and/or person_id. If an id is passed in only one result
  # will be retuned.
  # 
  # @param id [String]
  # @param person_id [String]
  def search_for_memberships(id: nil, person_id: nil, **args)
    q = []
    q << [ 'hasMember_ssim', person_id ] if person_id

    if id
      q << [ 'id', id ]
      args[:only_one] = true
    end

    args[:q] = q
    
    search_with_model_filter(Lna::Membership, **args)
  end

  # Search for a works based on id, collection id, start_date or any combination. If an id
  # is passed in only one result will be returned.
  # 
  #
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

    args[:only_one] = true if id
    args[:q] = q
    
    search_with_model_filter(Lna::Collection::Document, **args)
  end

  def search_for_licenses(id: nil, document_id: nil, **args)
    q = []
    q << ['license_ref_ssim', document_id] if document_id

    if id
      q << ['id', id]
      args[:only_one] = true
    end

    args[:q] = q
    
    search_with_model_filter([Lna::Collection::FreeToRead, Lna::Collection::LicenseReference],
                             **args)
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

    if id
      q = [['id', id]]
      args[:only_one] = true
    end

    args[:q] = q
    
    search_with_model_filter(models, **args)
  end
  
  # Search solr with a model filter. This method allows for many solr parameters that are passed
  # on to solr with the query. Based on rows and page, the start parameter is calculated. If query
  # is array it assumes its a array of array of field pairs, otherwise it passes the q parameter
  # as is.
  #
  # @param model [Class, Array<Class>] model to be filtered by
  # @param q [String, Array] query to be passed to solr, if an array it gets convered to a string.
  # @param only_one [Boolean] flad to limit number of documents to one, default false
  # @param rows [Integer, nil] max number of results to be returned by solr, default is set
  #   to 100000
  # @param sort [String, nil]  sort solr parameter 
  # @param page [Integer, nil] page of results to be displayed.
  # @param docs_only [Boolean] flag to limit response to only include documents, default true
  def search_with_model_filter(model, q: nil, only_one: false, rows: DEFAULT_MAX_ROWS, sort: nil,
                               page: nil, docs_only: true, **args)
    raise ArgumentError, 'Cannot calculate start param without rows.' if page && !rows
    
    q = '*:*' if q.blank?
    q = ActiveFedora::SolrQueryBuilder.construct_query(q) if q.is_a? Array
    
    args[:fq] = model_filter(model)
    args[:q] = q
    args[:rows] = rows if rows
    args[:sort] = sort if sort
    args[:start] = (rows * (page - 1)) + 1 if (rows && page && page > 1)
    
    solr_search(args, only_one, docs_only)
  end

  private

  # Uses ActiveFedora solr get method to query solr. Logs parameters received by solr.
  def solr_get(query, args = {})
    response = ActiveFedora::SolrService.get(query, args)
    logger.debug("Solr params: #{response['responseHeader']['params']}")
    response
  end
  
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

  # Method taken from ActiveFedora::SolrQueryBuilder.
  #
  # @private
  #
  def solr_escape(terms)
    RSolr.solr_escape(terms).gsub(/\s+/, "\\ ")
  end  
end
