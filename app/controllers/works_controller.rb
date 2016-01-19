class WorksController < ApiController
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]
  
  # GET works(/:page) or GET works/:start_date(/:page)
  def index
    page = params[:page]

    parameters = {
      start_date: params[:start_date] || nil,
      rows: MAX_ROWS,
      sort: 'date_dtsi desc, author_list_ssi asc'
    }

    @works = search_for_works(**parameters, page: page)

    next_page = search_for_works(**parameters, page: page + 1).count != 0
    
    respond_to do |f|
      response.headers['Link'] = link_headers('works/', page, next_page)
      f.jsonld { render :index, content_type: 'application/ld+json' }
    end
  end

  # POST works(/:page) or POST works/:start_date(/:page)
  def search
    page = params[:page]

    # TO DO: Search needs to be tested more throughly.
    query_map = {
      'bibo:authorList' => "author_list_tesi:(#{params['bibo:authorList']})",
      'bibo:doi'        => "doi_tesi:\"#{params['bibo:doi']}\"",
      'dc:title'        => "title_tesi:(#{params['dc:title']})",
      'bibo:abstract'   => "abstract_ss:(#{params['bibo:abstract']})",
      'org:member'      => "(({!join from=hasMember_ssim to=creator_id_ssi}{!join from=id to=Organization_ssim}label_tesi:\"#{params['org:member']}\") OR ({!join from=id to=creator_id_ssi}{!join from=id to=reportsTo_ssim}label_tesi:\"#{params['org:member']}\"))"
    }
    search_query = query_map.select{ |f, _| params[f] }.values.join(" AND ")
    
    parameters = {
      start_date: params[:start_date] || nil,
      rows: MAX_ROWS,
      q: search_query
    }
    @works = search_for_works(**parameters, page: page)

    next_page = search_for_works(**parameters, page: page + 1).count != 0
    
    respond_to do |f|
      response.headers['Link'] = link_headers('works/', page, next_page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end
end
