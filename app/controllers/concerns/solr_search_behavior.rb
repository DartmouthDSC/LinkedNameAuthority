# Wrapper around Active Fedora Solr classes with specific queries for use in the Lna.
# Controllers that include this module should also implement a not_found method. When a resource
# is not found, the not_found method is called.
module SolrSearchBehavior
  extend ActiveSupport::Concern

  # Hits Solr API with parameters given. Returns an array of results. This method allows the
  # most flexibility because all parameters can be used (or ommited).
  #
  # @param params [Hash] parameters to be given to Solr API
  def solr_search(params)
    logger.debug("Solr params: #{params.to_s}")
    ActiveFedora::SolrService.query(params[:q], params)
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
    q = [ ['has_model_ssim', Lna::Person.to_s ], ['id', id] ]
    search_with_query_array(q, true)
  end
  
  # Search for account(s). If id is given only one result is returned. If only a person_id
  # is given then all the accounts for that person are returned. 
  def search_for_accounts(id: nil, person_id: nil, orcid: false)
    q = [ ['has_model_ssim', Lna::Account.to_s ] ]
    q << [ 'account_ssim', person_id ] if person_id
    q << [ 'id', id ] if id
    q << ['title_tesi', 'ORCID'] if orcid

    only_one = orcid || ( id != nil )
    search_with_query_array(q, only_one)
  end
  # could be an alias for search_for_account


  # Searches for an account of the person given that has a "ORCID" as its title.
  #
  # @params person_id [String] full fedora id of the person
  # @return
  def search_for_orcid_account(person_id)
    search_for_accounts(person_id: person_id, orcid: true)
  end
  
  def search_for_memberships(id: nil, person_id: nil)
    q = [ ['has_model_ssim', Lna::Membership.to_s ] ]
    q << [ 'hasMember_ssim', person_id ] if person_id
    q << [ 'id', id ] if id

    search_with_query_array(q, id != nil)
  end

  def search_for_works(id:)
    q =  [ ['has_model_ssim', Lna::Collection::Document.to_s], ['id', params[:id]] ]
    search_with_query_array(q, true)
  end

  private

  def search_with_query_array(q, only_one)
    query = ActiveFedora::SolrQueryBuilder.construct_query(q)
    results = ActiveFedora::SolrService.query(query)

    if only_one && results.count == 1
      results.first
    elsif only_one
      not_found
    else
      results
    end
  end
end
