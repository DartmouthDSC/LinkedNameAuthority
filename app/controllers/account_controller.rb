class AccountController < CrudController
  before_action :get_request_path, only: [:create, :update, :destroy]
  
  PARAM_TO_MODEL = {
    'dc:title'                    => 'title',
    'foaf:accountName'            => 'account_name',
    'foaf:accountServiceHomepage' => 'account_service_homepage'
  }.freeze

  # POST /person/:person_id/account OR POST /organization/:organization_id/account
  def create
    acnt_holder = (@request_path == 'person') ?
                    search_for_persons(id: params[:person_id]) :
                    search_for_organizations(id: params[:organization_id])

    # Create account.
    attributes = params_to_attributes(account_params, account_holder_id: acnt_holder['id'])
    a = Lna::Account.new(attributes)
    render_unprocessable_entity && return unless a.save

    @account = search_for_id(a.id)
    location = "/#{@request_path}/#{FedoraID.shorten(acnt_holder['id'])}##{FedoraID.shorten(@account['id'])}"

    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
      f.html {redirect_to (@request_path == 'person') ? person_path(FedoraID.shorten(acnt_holder['id'])) : organization_path(FedoraID.shorten(acnt_holder['id']))}
    end
  end

  # PUT /person/:person_id/account/:id OR PUT /organization/:organization_id/account/:id
  def update
    acnt_holder = (@request_path == 'person') ? params[:person_id] : params[:organization_id]  
    account = search_for_accounts(id: params[:id], account_holder_id: acnt_holder)

    # Update account.
    attributes = params_to_attributes(account_params, put: true)
    a = Lna::Account.find(params[:id])
    render_unprocessable_entity && return unless a.update(attributes)

    @account = search_for_id(params[:id])

    super
  end

  # DELETE /person/:person_id/account/:id OR DELETE /organization/:org_id/account/:id
  def destroy
    acnt_holder = (@request_path == 'person') ? params[:person_id] : params[:organization_id]
    account = search_for_accounts(id: params[:id], account_holder_id: acnt_holder)

    # Delete account.
    a = Lna::Account.find(account['id'])
    a.destroy
    render_unprocessable_entity && return unless a.destroyed?

    super
  end
  
  private

  def account_params
    params.permit(PARAM_TO_MODEL.keys.concat(['person_id', 'organization_id']), :authenticity_token)
  end

  # get whether the request is for a person or an organization
  def get_request_path
    @request_path = request.original_url.gsub(root_url, '').split('/')[0]
  end
end
