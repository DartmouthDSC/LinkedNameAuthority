class Person::AccountController < ApiController

  before_action :convert_to_full_fedora_id
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  PARAM_TO_MODEL = {
      'dc:title'                    => 'title',
      'foaf:accountName'            => 'account_name',
      'foaf:accountServiceHomepage' => 'account_service_homepage'
  }.freeze

  # POST /person/:person_id/account
  def create
    person = search_for_id(params[:person_id])
    
    attributes = { account_holder_id: person['id'] }
    PARAM_TO_MODEL.select { |f, _| account_params[f] }.each do |f, v|
      attributes[v] = account_params[f]
    end

    # Create account.
    a = Lna::Account.create!(attributes)

    # Throw errors if not enough information
    @account = search_for_id(a.id)
    location = "/person/#{FedoraID.shorten(person['id'])}##{FedoraID.shorten(@account['id'])}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end

  # PUT /person/:person_id/account/:id
  def update
    account = search_for_accounts(id: params[:id], person_id: params[:person_id])
    
    attributes = {}
    PARAM_TO_MODEL.each do |f, v|
      attributes[v] = account_params[f] || ''
    end
    
    # Update account.
    Lna::Account.find(params[:id]).update(attributes)
    
    # what should happen if update doesnt work

    @account = search_for_id(params[:id])
    
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /person/:person_id/account/:id
  def destroy
    account = search_for_accounts(id: params[:id], person_id: params[:person_id])

    # Delete account.
    Lna::Account.find(account['id']).destroy

    # what to do if it doesnt work?

    respond_to do |f|
      f.jsonld { render json: '{ "status": "success" }', content_type: 'application/ld+json' }
    end
  end

  # GET /person/:person_id/orcid
  def orcid
    @account = search_for_orcid(params[:person_id])

    respond_to do |format|
      format.jsonld { render :orcid, content_type: 'application/ld+json' }
    end
  end
  
  private

  def convert_to_full_fedora_id
    [:id, :person_id].each { |i| params[i] = FedoraID.lengthen(params[i]) }
  end
  
  def account_params
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
