# Wrapper around Active Fedora Solr classes with specific queries for use in the Lna.
# Controllers that include this module should also implement a not_found method. When a resource
# is not found, the not_found method is called.
module SolrSearchBehavior
  extend ActiveSupport::Concern

  # Hits Solr API with parameters given. Returns an array of results. This method allows the
  # most flexibility because all parameters can be used (or ommited).
  #
  # @param params [Hash] parameters to be given to Solr API
  # @param only_one [Boolean] flag to limit results to only one
  def solr_search(params, only_one = false)
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
  # @params id [String] full fedora id used for lookup
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
  # @params id [String] full fedora id used for lookup
  def search_for_id(id)
    begin
      search_for_id!(id)
    rescue
      not_found
    end
  end

  # Searches Solr for a Lna::Person with the given id. If there isn't only one result the
  # not_found method is called.
  #
  #
  def search_for_person(id)
    params = {
      fq: model_filter(Lna::Person),
      q:  field_query([['id', id]])
    }
    solr_search(params, true)
  end
  
  # Search for account(s). If id is given only one result is returned. If only a person_id
  # is given then all the accounts for that person are returned. 
  def search_for_accounts(id: nil, person_id: nil, orcid: false)
    q = []
    q << ['account_ssim', person_id] if person_id
    q << ['id', id] if id
    q << ['title_tesi', 'ORCID'] if orcid
    
    params = {
      fq: model_filter(Lna::Account),
      q:  field_query(q)
    }

    only_one = orcid || ( id != nil )
    solr_search(params, only_one)
  end
  # could be an alias for search_for_account


  # Searches for an account of the person given that has a "ORCID" as its title.
  #
  # @params person_id [String] full fedora id of the person
  # @return
  def search_for_orcid(person_id)
    search_for_accounts(person_id: person_id, orcid: true)
  end
  
  def search_for_memberships(id: nil, person_id: nil)
    q = []
    q << [ 'hasMember_ssim', person_id ] if person_id
    q << [ 'id', id ] if id

    params = {
      fq: model_filter(Lna::Membership),
      q: field_query(q)
    }
    
    solr_search(params, id != nil)
  end

  def search_for_works(id:)
    params = {
      fq: model_filter(Lna::Collection::Document),
      q:  field_query([['id', id]])
    }
    solr_search(params, true)
  end

  private

  #params class name
  def model_filter(class_name)
    "has_model_ssim:\"#{class_name.to_s}\""
  end

  def field_query(field_array, join_with = " AND ")
    field_array.map { |i| "#{i[0]}:#{solr_escape(i[1])}" }.join(join_with)
  end

  # method taken from ActiveFedora::SolrQueryBuilder
  def solr_escape(terms)
    RSolr.solr_escape(terms).gsub(/\s+/, "\\ ")
  end
end
