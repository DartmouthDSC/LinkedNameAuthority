class AccountController < CrudController
  before_action :load_account_holder
  load_and_authorize_resource :account, param_method: :attributes, class: 'Lna::Account',
                              through: :account_holder
  before_action :account_not_nil
  
  PARAM_TO_MODEL = {
    'dc:title'                    => 'title',
    'foaf:accountName'            => 'account_name',
    'foaf:accountServiceHomepage' => 'account_service_homepage'
  }.freeze

  # POST /person/:person_id/account OR POST /organization/:organization_id/account
  def create
    @account.save!

    @account = search_for_id(@account.id)
    location = "/#{@request_path}/#{FedoraID.shorten(@account_holder.id)}##{FedoraID.shorten(@account['id'])}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
      f.html {redirect_to (@request_path == 'person') ? person_path(FedoraID.shorten(acnt_holder['id'])) : organization_path(FedoraID.shorten(acnt_holder['id']))}
    end
  end

  # PUT /person/:person_id/account/:id OR PUT /organization/:organization_id/account/:id
  def update
    @account.update(attributes)
    @account.save!
    
    @account = search_for_id(params[:id])

    super
  end

  # DELETE /person/:person_id/account/:id OR DELETE /organization/:org_id/account/:id
  def destroy
    @account.destroy!
    
    super
  end
  
  private

  def account_not_nil
    raise ActiveFedora::ObjectNotFound, "account id not valid" if @account.nil?
  end
  
  def attributes
    extra = {}
    extra[:account_holder_id] = @account_holder.id if params[:action] == 'create'
    params_to_attributes(account_params, extra)
  end
  
  def account_params
    PARAM_TO_MODEL.keys.each { |p| params.require(p) }
    params.permit(
      PARAM_TO_MODEL.keys.concat(['person_id', 'organization_id', :authenticity_token])
    )
  end

  # Get whether the request is for a person or an organization and load the appropriate
  # account holder.
  def load_account_holder
    @request_path = request.original_url.gsub(root_url, '').split('/')[0]
    @account_holder = if @request_path == 'person'
                        Lna::Person.find(params[:person_id])
                      else
                        begin
                          Lna::Organization.find(params[:organization_id])
                        rescue ActiveFedora::ObjectNotFoundError
                          Lna::Organization::Historic.find(params[:organization_id])
                        end
                      end
  end
end
