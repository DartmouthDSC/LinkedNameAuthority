class PersonController < CrudController
  before_action :convert_org_to_fedora_id

  PARAM_TO_MODEL = {
      'foaf:name'       => 'full_name',
      'foaf:givenName'  => 'given_name',
      'foaf:familyName' => 'family_name',
      'foaf:title'      => 'title',
      'foaf:mbox'       => 'mbox',
      'foaf:image'      => 'image',
      'foaf:homepage'   => 'homepage',
      'org:reportsTo'   => 'primary_org_id'
  }.freeze
  
  # GET /person(/:id)
  def show
    @person = search_for_persons(id: params[:id])
    @memberships = search_for_memberships(person_id: @person['id'])
    @accounts = search_for_accounts(account_holder_id: @person['id'])
    @short_id = FedoraID.shorten(@person['id'])

    # primary organization and all the membership's organizations
    org_ids = [ @person['reportsTo_ssim'].first ]
    @memberships.each do |m|
      org_ids << m['Organization_ssim'].first
    end

    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = ActiveFedora::SolrService.query(query)

    super
  end

  # POST /person
  def create
    # Create person.
    attributes = params_to_attributes(person_params)
    p = Lna::Person.new(attributes)
    render_unprocessable_entity && return unless p.save
    
    @person = search_for_id(p.id)

    location = person_path(id: FedoraID.shorten(p.id))
    
    respond_to do |format|
      format.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end

  # PUT /person/:id
  def update
    person = search_for_persons(id: params[:id])

    # Update person.
    attributes = params_to_attributes(person_params, put: true)
    p = Lna::Person.find(person['id'])
    render_unprocessable_entity && return unless p.update(attributes)
    
    @person = search_for_persons(id: params[:id])

    super
  end

  # DELETE /person/:id
  def destroy
    p = search_for_persons(id: params[:id])

    # Delete person
    person = Lna::Person.find(p['id'])
    person.destroy
    render_unprocessable_entity && return unless person.destroyed?
    
    super
  end

  private

  def convert_org_to_fedora_id
    params['org:reportsTo'] = org_uri_to_fedora_id(params['org:reportsTo'])
  end
  
  def person_params
    params.permit('id', 'foaf:name', 'foaf:givenName', 'foaf:familyName', 'foaf:title',
                  'foaf:mbox', 'foaf:image', 'org:reportsTo', 'id', 'authenticity_token', 'foaf:homepage' => [])
  end
end