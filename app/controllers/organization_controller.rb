class OrganizationController < CrudController
  before_action :convert_sub_and_super_org_ids, only: [:create, :update]
  
  PARAM_TO_MODEL = {
    'org:identifier'         => 'hr_id',
    'skos:prefLabel'         => 'label',
    'skos:altLabel'          => 'alt_label',
    'owltime:hasBeginning'   => 'begin_date',
    'vcard:post-office-box' => 'hinman_box',
    'org:purpose'            => 'kind'
  }.freeze

  # GET /organization/:id
  def show
    @organization = search_for_organizations(id: params[:id])
    
    ids = ['subOrganizationOf_ssim',
           'hasSubOrganization_ssim'].map{ |i| @organization[i] }.compact.flatten
    @related_orgs = search_for_ids(ids)

    @accounts = search_for_accounts(account_holder_id: @organization['id'])

    ids = ['resultedFrom_ssim', 'changedBy_ssim'].map{ |i| @organization[i] }.compact.flatten
    @change_events = search_for_ids(ids)
    super
  end

  # POST /organization
  def create
    authorize! :create, Lna::Organization

    attributes = params_to_attributes(organization_params)
    
    o = Lna::Organization.create!(attributes) do |o|
      o.super_organization_ids = organization_params['org:subOrganizationOf']  
    end

    # Could not get sub organizations to save any other way.
    o.sub_organization_ids = organization_params['org:hasSubOrganization']
    o.save!
    
    @organization = search_for_id(o.id)

    location = organization_path(id: FedoraID.shorten(o.id))

    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json'}
    end
  end

  # PUT /organization/:id
  def update
    organization = search_for_organizations(id: params[:id])

    # Update organization (could be historic or active)
    o = ActiveFedora::Base.find(organization['id'])
    authorize! :update, o
    if o.class == Lna::Organization
      attributes = params_to_attributes(organization_params,
                                        sub_organization_ids:
                                          params['org:hasSubOrganization'],
                                        super_organization_ids:
                                          params['org:subOrganizationOf'])
    else
      attributes = params_to_attributes(organization_params,
                                        historic_placement: params['lna:historicPlacement'],
                                        end_date: params['owltime:hasEnd'])
    end

    o.update_attributes(attributes)
    o.save!

    @organization = search_for_organizations(id: organization['id'])
    
    super
  end

  # DELETE /organization/:id
  def destroy
    organization = ActiveFedora::Base.find(params['id'])
    authorize! :destroy, organization
    organization.destroy!
   
    super
  end

  private

  def organization_params
    params.require('skos:prefLabel')
    params.require('owltime:hasBeginning')
    params.permit('id', 'org:identifier', 'skos:prefLabel', 'owltime:hasBeginning', 
                  'lna:historicPlacement', 'owltime:hasEnd', 'vcard:post-office-box',
                  'org:purpose', 'authenticity_token', 'skos:altLabel' => [],
                  'org:hasSubOrganization' => [], 'org:subOrganizationOf' => [])
  end
    
  def convert_sub_and_super_org_ids
    ['org:hasSubOrganization', 'org:subOrganizationOf'].each do |o|
      org_uri_to_fedora_id!(o) unless params[o].blank?
    end
  end
end
