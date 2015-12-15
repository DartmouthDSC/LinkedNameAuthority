class OrganizationsController < ApiController

  before_action :default_to_first_page, only: [:index, :search]
  
  ROWS = 100.freeze

  # GET /organizations
  def index
    page = params['page']
    params =
      {
        rows: ROWS,
        sort: 'label_tesi asc',
        fq: 'has_model_ssim:"Lna::Organization"',
        q: "*:*"
      }
    params[:start] = page * ROWS if page > 1
    
    @resulting_orgs = query(params)

    org_ids = @resulting_orgs.map { |p| p['subOrganizationOf_ssim'] }.flatten
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = @resulting_orgs + ActiveFedora::SolrService.query(query)

    respond_to do |format|
      response.headers['Link'] = link_headers('organizations/', page, ROWS, params)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  def search
    page = params['page']
    
  end
end
