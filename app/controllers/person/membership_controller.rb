class Person::MembershipController < CrudController
  load_resource :person, class: 'Lna::Person'
  before_action :convert_org_to_fedora_id, except: :destroy
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
    @membership.save!

    @membership = search_for_id(@membership.id) # gets solr doc
    
    location = "/person/#{FedoraID.shorten(@person.id)}##{FedoraID.shorten(@membership['id'])}"
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
      f.html { redirect_to person_path(FedoraID.shorten(person['id'])) }
    end
  end

  # PUT /person/:person_id/membership/:id
  def update
    @membership.update(attributes)
    @membership.save!
    
    @membership = search_for_id(params[:id]) # gets solr doc
    
    super
  end

  # DELETE /person/:person_id/membership/:id
  def destroy
    @membership.destroy!

    super
  end
  
  private

  def membership_not_nil
    raise ActiveFedora::ObjectNotFoundError, "membership id not valid" if @membership.nil?
  end
  
  def attributes
    extra = {}
    extra[:person_id] = params[:person_id] if params[:action] == 'create'

    params_to_attributes(membership_params, extra)
  end

  def convert_org_to_fedora_id
    puts params['org:organization']
    org_uri_to_fedora_id!('org:organization')
  end
  
  def membership_params
    params.require('org:organization')
    params.require('vcard:title')
    params.require('owltime:hasBeginning')
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
