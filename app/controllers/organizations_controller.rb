class OrganizationsController < ApiController
  before_action :default_to_first_page, only: [:index, :search]

  # GET /organizations
  def index
    page = params['page']

    parameters = { rows: MAX_ROWS, sort: 'label_tesi asc' }
    
    @resulting_orgs = search_for_active_organizations(**parameters, page: page)

    org_ids = @resulting_orgs.map { |p| p['subOrganizationOf_ssim'] }.flatten
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = @resulting_orgs + ActiveFedora::SolrService.query(query)

    next_page = search_for_active_organizations(**parameters, page: page + 1).count != 0

    respond_to do |format|
      response.headers['Link'] = link_headers('organizations/', page, next_page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  # Potential search terms. 
  # {
  #    "org:identifier": "its",
  #    "skos:pref_label": "Library",
  #    "skos:alt_label": "AHRC",
  #    "org:subOrganizationOf": "ITS"
  # }
  def search
    page = params['page']

    parameters = { rows: MAX_ROWS, sort: 'label_tesi asc' }

    search_for_organizations(**parameters, page: page)
    
    
    
  end
end
