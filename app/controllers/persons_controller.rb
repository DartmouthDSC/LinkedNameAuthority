class PersonsController < CollectionController
  before_action :convert_org_to_fedora_id, only: :search

  # GET /persons
  def index
    @page = params['page']
    
    result = search_for_persons(
      rows: MAX_ROWS,
      sort: 'family_name_ssi asc, given_name_ssi asc',
      docs_only: false,
      page: @page
    )
    @persons = result['response']['docs']
    @organizations = get_primary_orgs(@persons)

    respond_to do |format|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, @page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /persons
  def search
    page = params['page']

    # Search query for each field in this search
    query_map = {
      'foaf:name'       => grouping_query('full_name_tesi', params['foaf:name']),
      'foaf:givenName'  => grouping_query('given_name_tesi', params['foaf:givenName']),
      'foaf:familyName' => grouping_query('family_name_tesi', params['foaf:familyName']),
      'org:member'      => "(#{join_query('id', 'reportsTo_ssim', 'label_tesi', params['org:member'])} OR #{field_query('reportsTo_ssim', params['org:member'])})"
    }
    
    result = search_for_persons(
      rows:      MAX_ROWS,
      q:         query_map.select { |f, _| !params[f].blank? }.values.join(" AND "),
      page:      page,
      docs_only: false
    )
    @persons = result['response']['docs']
    @organizations = get_primary_orgs(@persons)
    
    respond_to do |format|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, page)
      format.jsonld { render :search, content_type: 'application/ld+json' }
      format.html
    end
  end

  private
  
  # Get primary organizations for an array of Lna::Person solr documents.
  def get_primary_orgs(persons)
    org_ids = persons.map { |p| p['reportsTo_ssim'].first }
    search_for_ids(org_ids.uniq)
  end

  def convert_org_to_fedora_id
    params['org:member'] = org_uri_to_fedora_id(params['org:member'])
  end
end
