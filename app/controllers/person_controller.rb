class PersonController < CrudController
  before_action :convert_org_to_fedora_id, only: [:create, :update]
  load_and_authorize_resource :person, param_method: :attributes, class: 'Lna::Person',
                              only: [:create, :update, :destroy]
  
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
  
  # GET /person/:id
  def show
    @person = search_for_persons(id: params[:id])
    @memberships = search_for_memberships(person_id: @person['id'])
    @accounts = search_for_accounts(account_holder_id: @person['id'])

    # primary organization and all the membership's organizations
    org_ids = [ @person['reportsTo_ssim'].first ]
    @memberships.each do |m|
      org_ids << m['Organization_ssim'].first
    end

    @organizations = search_for_ids(org_ids.uniq)

    super
  end

  # POST /person
  def create
    @person.save!
    
    @person = search_for_id(@person.id)

    location = person_path(FedoraID.shorten(@person['id']))
    
    respond_to do |format|
      format.jsonld { render :create, status: :created, location: location,
                             content_type: 'application/ld+json' }
      format.html { redirect_to location }
    end
  end

  # PUT /person/:id
  def update
    @person.update(attributes)
    @person.save!
    
    @person = search_for_persons(id: params[:id])

    super
  end

  # DELETE /person/:id
  def destroy
    @person.destroy!
    
    super
  end

  private

  def attributes
    params_to_attributes(person_params)
  end

  def convert_org_to_fedora_id
    org_uri_to_fedora_id!('org:reportsTo')
  end
  
  def person_params
    ['org:reportsTo', 'foaf:name', 'foaf:givenName', 'foaf:familyName'].each do |p|
      params.require(p)
    end
    params.permit('id', 'foaf:name', 'foaf:givenName', 'foaf:familyName', 'foaf:title',
                  'foaf:mbox', 'foaf:image', 'org:reportsTo', 'authenticity_token',
                  'foaf:homepage' => [])
  end
end
