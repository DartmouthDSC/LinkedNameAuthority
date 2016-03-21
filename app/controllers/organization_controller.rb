class OrganizationController < CrudController
  before_action :convert_sub_and_super_org_ids, only: [:create, :update]
  
  PARAM_TO_MODEL = {
    'org:identifier'       => 'code',
    'skos:pref_label'      => 'label',
    'skos:alt_label'       => 'alt_label',
    'owltime:hasBeginning' => 'begin_date',
    'vcard:postal-box'     => 'hinman_box',
    'org:purpose'          => 'purpose'
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
    # Create organization
    attributes = params_to_attributes(organization_params)
    o = Lna::Organization.new(attributes)
    render_unprocessable_entity && return unless o.save

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
    if o.class == Lna::Organization
      attributes = params_to_attributes(organization_params, put: true,
                                        sub_organization_ids: params['org:hasSubOrganization'],
                                        super_organization_ids: params['org:subOrganizationOf'])
    else
      attributes = params_to_attributes(organization_params, put: true,
                                        historic_placement: params['lna:historicPlacement'],
                                        end_date: params['owltime:hasEnd'])
    end
    render_unprocessable_entity && return unless o.update(attributes)

    @organization = search_for_organizations(id: organization['id'])
    
    super
  end

  # DELETE /organization/:id
  def destroy
    o = search_for_organizations(id: params[:id])

    # Delete organization
    organization = ActiveFedora::Base.find(o['id'])
    organization.destroy
    render_unprocessable_entity && return unless organization.destroyed?
   
    super
  end

  private

  def organization_params
    params.permit('id', 'org:identifier', 'skos:pref_label', 'owltime:hasBeginning', 
                  'lna:historicPlacement', 'owltime:hasEnd', 'vcard:postal-box',
                  'org:purpose', 'authenticity_token', 'skos:alt_label' => [],
                  'org:hasSubOrganization' => [], 'org:subOrganizationOf' => [])
  end
    
  def convert_sub_and_super_org_ids
    ['org:hasSubOrganization', 'org:subOrganizationOf'].each do |o|
      if params[o].kind_of?(Array)
        params[o].map { |i| org_uri_to_fedora_id(i) }
      end
    end
  end
end

  
