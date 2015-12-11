class OrganizationsController < ApiController

  before_action :page_default_to_first, only: [:index, :search]
  
  ROWS = 100.freeze

  # GET /organizations
  def index
    page = params['page']
    args =
      {
        rows: ROWS,
        sort: 'label_tesi asc',
        fq: 'has_model_ssim:"Lna::Organization"'
      }
    args[:start] = page * ROWS if page > 1
    
    @organizations = ActiveFedora::SolrService.query("*:*", args)

#    org_ids = @organizations.map { |p| p['reportsTo_ssim'].first }
#    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
#    @organizations = ActiveFedora::SolrService.query(query)

    respond_to do |format|
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  def search
    page = params['page']
    
  end
end
