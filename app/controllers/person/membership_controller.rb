class Person::MembershipController < CrudController
  before_action :convert_org_to_fedora_id
  #  before_action :verify_authorization!, only: [:create, :update, :destroy]
  load_resource :person, class: 'Lna::Person'
  load_and_authorize_resource :membership, param_method: :attributes, class: 'Lna::Membership',
                              through: :person
  before_action :membership_not_nil

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
#    person = search_for_id(params[:person_id])

    # Create membership
#    attributes = params_to_attributes(membership_params, person_id: person['id'])
#    m = Lna::Membership.new(attributes)

  #  authorize! :create, m
    
    render_unprocessable_entity && return unless @membership.save

    @membership = search_for_id(@membership.id) # gets solr doc
    
    location = "/person/#{FedoraID.shorten(@person.id)}##{FedoraID.shorten(@membership['id'])}"
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
    end
  end

  # PUT /person/:person_id/membership/:id
  def update
 #   membership = search_for_memberships(id: params[:id], person_id: params[:person_id])

    # Update membership.
#    m = Lna::Membership.find(params[:id])
    
#   authorize! :update, m
    
#    attributes = params_to_attributes(membership_params, put: true)
    render_unprocessable_entity && return unless @membership.update(attributes)
    
    @membership = search_for_id(params[:id]) # gets solr doc
    
    super
  end

  # DELETE /person/:person_id/membership/:id
  def destroy
  #  membership = search_for_memberships(id: params[:id], person_id: params[:person_id])

    # Delete membership
#    m = Lna::Membership.find(membership['id'])

#    authorize! :destroy, m

    @membership.destroy
    render_unprocessable_entiry && return unless @membership.destroyed?

    super
  end
  
  private

  def membership_not_nil
    raise ActiveFedora::ObjectNotFoundError, "membership id not valid" if @membership.nil?
  end
  
  def attributes
    extra = {}
    case params[:action].to_sym
    when :update
      extra[:put] = true 
    when :create
      extra[:person_id] = params[:person_id]
    end

    params_to_attributes(membership_params, extra)
  end

  # def verify_authorization!
  #   authorize! params[:action].to_sym, Lna::Membership
  # end
  
  def convert_org_to_fedora_id
    params['org:organization'] = org_uri_to_fedora_id(params['org:organization'])
  end
  
  def membership_params
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
