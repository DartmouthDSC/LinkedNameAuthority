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

    query_map = {
      'dc:authorList' => "author_list_tesi:#{params['dc:authorList']}",
      'bibo:doi'      => "doi_tesi:\"#{params['bibo:doi']}\"",
      'dc:title'      => "title_tesi:#{params['title_tesi']}",
      'bibo:abstract' => "abstract_ss:#{params['abstract_ss']}",
      'org:member'    => ""
    }

    parameters = {
      start_date: params[:start_date] || nil,
      rows: MAX_ROWS,
    }
    @works = search_for_works(**parameters, page: page)

    respond_to do |f|
      response.headers['Link'] = link_headers('works/', page, next_page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end
end
