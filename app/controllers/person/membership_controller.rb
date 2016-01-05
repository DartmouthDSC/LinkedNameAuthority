class Person::MembershipController < ApiController

  before_action :convert_to_full_fedora_id
  before_action :convert_org_to_fedora_id
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  PARAM_TO_MODEL = {
      'org:organization'     => 'organization_id',
      'vcard:email'          => 'email',
      'vcard:title'          => 'title',
      'vcard:street-address' => 'street_address',
      'vcard:postal-code'    => 'postal_code',
      'vcard:country-name'   => 'country_name',
      'vcard:locality'       => 'locality',
      'owltime:hasBeginning' => 'begin_date',
      'owltime:hasEnd'       => 'end_date'
  }.freeze

  # POST /person/:person_id/membership
  def create
    person = search_for_id(params[:person_id])

    logger.debug("membership_params = #{membership_params}")
    
    attributes = { person_id: person['id']}
    PARAM_TO_MODEL.select { |f, _| membership_params[f] }.each do |f, v|
      attributes[v] = membership_params[f]
    end

    # Create membership
    m = Lna::Membership.create!(attributes)

    # Throw errors if not enough information
    @membership = search_for_id(m.id)
    location = "/person/#{FedoraID.shorten(person['id'])}##{FedoraID.shorten(@membership['id'])}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end


  # PUT /person/:person_id/membership/:id
  def update
    membership = search_for_memberships(id: params[:id], person_id: params[:person_id])
    
    # update person's account
    attributes = {}
    PARAM_TO_MODEL.each do |f, v|
      attributes[v] = membership_params[f] || ''
    end

    Lna::Membership.find(params[:id]).update(attributes)
    
    # what should happen if update doesnt work

    @membership = search_for_id(params[:id])
    
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /person/:person_id/membership/:id
  def destroy
    membership = search_for_memberships(id: params[:id], person_id: params[:person_id])

    # Delete account.
    Lna::Membership.find(membership['id']).destroy

    # what to do if it doesnt work?

    respond_to do |f|
      f.jsonld { render json: '{ "status": "success" }', content_type: 'application/ld+json' }
    end
  end
  
  private

  def convert_to_full_fedora_id
    [:id, :person_id].each { |i| params[i] = FedoraID.lengthen(params[i]) }
  end

  def convert_org_to_fedora_id
    params['org:organization'] = org_uri_to_fedora_id(params['org:organization'])
  end
  
  def membership_params
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
