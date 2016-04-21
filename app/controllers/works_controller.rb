class WorksController < CollectionController
  
  # GET works(/:page) or GET works/:start_date(/:page)
  def index
    @page = params[:page]

    result = search_for_works(
      start_date: params[:start_date] || nil,
      rows: MAX_ROWS,
      sort: 'date_dtsi desc',
      page: @page,
      docs_only: false
    )
    @works = result['response']['docs']
    
    respond_to do |f|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, @page)
      f.jsonld { render :index, content_type: 'application/ld+json' }
      f.html
    end
  end

  # POST works(/:page) or POST works/:start_date(/:page)
  def search
    @page = params[:page]

    query_map = {
      'bibo:authorList' => grouping_query('author_list_tesim', params['bibo:authorList']),
      'bibo:doi'        => field_query('doi_tesi', params['bibo:doi']),
      'dc:title'        => grouping_query('title_tesi', params['dc:title']),
      'bibo:abstract'   => grouping_query('abstract_tesi', params['bibo:abstract']), #field query and
      'org:member'      => "(({!join from=hasMember_ssim to=creator_id_ssi}{!join from=id to=Organization_ssim}label_tesi:\"#{params['org:member']}\") OR ({!join from=id to=creator_id_ssi}{!join from=id to=reportsTo_ssim}label_tesi:\"#{params['org:member']}\"))"
    }
    
    result = search_for_works(
      start_date: params[:start_date] || nil,
      rows:       MAX_ROWS,
      q:          query_map.select{ |f, _| !params[f].blank? }.values.join(" AND "),
      page:       @page,
      docs_only:  false
    )

    @works = result['response']['docs']
    respond_to do |f|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, @page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
      f.html
    end
  end
end
