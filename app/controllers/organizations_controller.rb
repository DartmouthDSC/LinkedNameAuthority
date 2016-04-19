class OrganizationsController < ApiController
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]

  # GET /organizations
  def index
    page = params['page']

    result = search_for_active_organizations(
      rows: MAX_ROWS,
      sort: 'label_ssi asc',
      page: page,
      docs_only: false
    )
    @organizations = result['response']['docs']
    @organizations += parent_organizations(@organizations)

    respond_to do |format|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, page)
      format.jsonld { render :index, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /organizations
  def search
    page = params['page']

    # identifier exact match, pref_label and alt_label fuzzy(but not solr fuzzy)
    query_map = {
      'skos:prefLabel'       => complexphrase_query('label_tesi', params['skos:prefLabel']),
      'skos:altLabel'        => field_query('alt_label_tesim', params['skos:altLabel']),
      'org:subOrganizationOf' => join_query('id', 'subOrganizationOf_ssim', 'label_tesi',
                                      params['org:subOrganizationOf'])
    }

    result = search_for_organizations(
      rows: MAX_ROWS,
      q: query_map.select{ |f, _| !params[f].blank? }.values.join(" AND "),
      page: page,
      docs_only: false
    )
    @organizations = result['response']['docs']
    @organizations += parent_organizations(@organizations)

    respond_to do |f|
      response.headers['Link'] = link_headers(result['response']['numFound'], MAX_ROWS, page)
      f.jsonld { render :search, content_type: 'application/ld+json' }
    end
  end

  private

  # Returns parent organization that are not already part of the organizations listed.
  def parent_organizations(orgs)
    ids = orgs.map { |o| o['id'] }
    parents = orgs.map{ |p| p['subOrganizationOf_ssim'] }.flatten.uniq.reject{ |p| ids.include?(p) }
    search_for_ids(parents)
  end
end
