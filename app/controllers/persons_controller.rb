class PersonsController < ApiController
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]

  # GET /persons
  def index
    page = params['page']
    parameters = { rows: MAX_ROWS, sort: 'family_name_ssi asc, given_name_ssi asc' }
    
    @persons = search_for_persons(**parameters, page: page)
    @organizations = get_primary_orgs(@persons)

    next_page = search_for_persons(**parameters, page: page + 1).count > 1
    
    respond_to do |format|
      response.headers['Link'] = link_headers('persons/', page, next_page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /persons
  def search
    page = params['page']

    # Search query for each field in this search
    query_map = {
      'foaf:name'       => "full_name_tesi:\"#{params['foaf:name']}\"",
      'foaf:givenName'  => "given_name_ssi:\"#{params['foaf:givenName']}\"",
      'foaf:familyName' => "family_name_ssi:\"#{params['foaf:familyName']}\"",
      'org:member'      => "({!join from=id to=reportsTo_ssim}label_tesi:\"#{params['org:member']}\")"
    }
    search_query = query_map.select { |f, _| params[f] }.values.join(" AND ")
    
    parameters = { rows: MAX_ROWS, q: search_query }
    
    @persons = search_for_persons(**parameters, page: page)
    @organizations = get_primary_orgs(@persons)

    next_page = search_for_persons(**parameters, page: page + 1).count != 0
    
    respond_to do |format|
      response.headers['Link'] = link_headers('persons/', page, next_page)
      format.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end

  private
  
  # Get primary organizations for an array of Lna::Person solr documents.
  def get_primary_orgs(persons)
    org_ids = persons.map { |p| p['reportsTo_ssim'].first }
    search_for_ids(org_ids.uniq)
  end
end
