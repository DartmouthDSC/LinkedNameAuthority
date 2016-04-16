class OrganizationsController < ApiController
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]

  # GET /organizations
  def index
    page = params['page']

    parameters = { rows: MAX_ROWS, sort: 'label_ssi asc' }
    
    @organizations = search_for_active_organizations(**parameters, parents: true, page: page)

    next_page = search_for_active_organizations(**parameters, page: page + 1).count != 0

    respond_to do |format|
      response.headers['Link'] = link_headers('organizations/', page, next_page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  def search
    page = params['page']

    # identifier exact match, prefLabel and altLabel fuzzy(but not solr fuzzy)
    query_map = {
      'org:identifier'        => "code_tesi:\"#{params['org:identifier']}\"",
      'skos:prefLabel'       => "label_tesi:#{params['skos:prefLabel']}",
      'skos:altLabel'        => "alt_label_tesim:\"#{params['skos:altLabel']}\"",
      'org:subOrganizationOf' => "{!join from=id to=subOrganizationOf_tesim}label_tesi:\"#{params['org:subOrganizationOf']}"
    }
    search_query = query_map.select{ |f, _| params[f] }.values.join(" AND ")
    
    parameters = { rows: MAX_ROWS, q: search_query }

    @organizations = search_for_organizations(**parameters, parents: true, page: page)

    next_page = search_for_persons(**parameters, page: page + 1).count != 0

    respond_to do |f|
      response.headers['Link'] = link_headers('organizations/', page, next_page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end
end
