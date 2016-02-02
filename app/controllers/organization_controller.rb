class OrganizationController < ApiController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :convert_to_full_fedora_id

  PARAM_TO_MODEL = {
    'org:identifier'         => 'code_tesi',
    'skos:pref_label'        => 'label_tesi',
    'skos:alt_label'         => 'alt_label_tesim',
    'owltime:hasBeginning'   => 'begin_date_dtsi',
    'org:hasSubOrganization' => '',
    'org:subOrganizationOf'  => ''
  }.freeze
  # super and sub organization

  # GET /organization/:id
  def show
    # @organization
    # @accounts
    # @change_events
  end

  # POST /organization
  def create
    attributes = params_to_attributes(organization_params)

    o = Lna::Organization.create!(attributes)

    @organization = search_for_id(o.id)

    location = "/organization/
    
  end

  # PUT /organization/:id
  def update
  end

  # DELETE /organization/:id
  def destroy
  end

  private

  def organization_params
    params.permit(PARAM_TO_MODEL.keys << 'id')
  end
end

  
