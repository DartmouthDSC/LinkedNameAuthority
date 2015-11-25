class PersonsController < ApiController

  before_action :page_param, only: [:index, :search]
  
  ROWS = 100.freeze

  # GET /persons
  def index
    page = params['page']
    args =
      {
        rows: ROWS,
        sort: 'family_name_ssi asc, given_name_ssi asc',
        fq: 'has_model_ssim:"Lna::Person"'
      }
    args[:start] = page * ROWS if page > 1
    
    @persons = ActiveFedora::SolrService.query("*:*", args)

    org_ids = @persons.map { |p| p['reportsTo_ssim'].first }
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = ActiveFedora::SolrService.query(query)

    respond_to do |format|
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  def search
    page = params['page']
    
  end
  
  private

  def page_param
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end
end
