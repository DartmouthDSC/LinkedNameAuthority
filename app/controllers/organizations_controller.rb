class OrganizationsController < ApiController
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]

  # GET /organizations
  def index
    @page = params['page']

    result = search_for_active_organizations(
      rows: MAX_ROWS,
      sort: 'label_ssi asc',
      parents: true,
      page: @page,
      raw: true
    )
    @organizations = result['response']['docs']

    respond_to do |format|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, @page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  def search
    page = params['page']

    # identifier exact match, prefLabel and altLabel fuzzy(but not solr fuzzy)
    query_map = {
      'skos:pref_label'       => complexphrase('label_tesi', params['skos:pref_label']),
      'skos:alt_label'        => "alt_label_tesim:\"#{params['skos:alt_label']}\"",
      'org:subOrganizationOf' => "{!join from=id to=subOrganizationOf_tesim}label_tesi:\"#{params['org:subOrganizationOf']}"
    }
    search_query = query_map.select{ |f, _| params[f] }.values.join(" AND ")
    
    result = search_for_organizations(
      rows: MAX_ROWS,
      q: search_query,
      parents: true,
      page: page,
      raw: true
    )
    @organizations = result['response']['docs']

    respond_to do |f|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end

  private

  def complexphrase(field, phrase)
    return unless phrase
    phrase = "\"#{phrase}\"" if phrase.match(/\s/)
    "{!complexphrase inOrder=false}#{field}:#{phrase}"
  end
end
