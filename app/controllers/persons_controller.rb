class PersonsController < ApiController

  skip_before_action :verify_authenticity_token, only: [:index, :search]
  
  # default_to_first_page
  before_action :page_default_to_first, only: [:index, :search]
  
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

    @organizations = get_primary_orgs(@persons)

    respond_to do |format|
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /persons
  def search
    page = params['page']

    # org:member maps to the pref label for an organization

    # Search query for each field in this search
    query_map = {
      'foaf:name' => "full_name_tesi:\"#{params['foaf:name']}\"",
      'foaf:givenName' => "given_name_ssi:\"#{params['foaf:givenName']}\"",
      'foaf:familyName' => "family_name_ssi:\"#{params['foaf:familyName']}\"",
      'org:member' => "{!join from=id to=reportsTo_ssim}label_tesi:\"#{params['org:member']}\""
    }

    search_query = ''
    query_map.each do |field, query|
      if params[field]
        search_query << " AND " unless search_query.blank?
        search_query << query
      end
    end
      
    # Blacklight.logger.debug - or something similar to display solr query
    # logger.debug("solr query = #{search_query}");
    
    args =
      {
        rows: ROWS,
        fq: 'has_model_ssim:"Lna::Person"'
      }
    args[:start] = page * ROWS if page > 1

    @persons = ActiveFedora::SolrService.query(search_query, args)
    @organizations = get_primary_orgs(@persons)

#    response.headers['link'] = 'bunnies'
    
    respond_to do |format|
      format.jsonld { render :search, content_type: 'application/ld+json' }
    end   
  end

  private
  
  # Get primary organizations for an array of Lna::Person solr documents.
  def get_primary_orgs(persons)
    org_ids = persons.map { |p| p['reportsTo_ssim'].first }
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    ActiveFedora::SolrService.query(query)
  end
end
