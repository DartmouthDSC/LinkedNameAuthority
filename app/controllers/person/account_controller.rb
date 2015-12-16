class Person::AccountController < ApiController

  before_action :convert_to_full_fedora_id
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  PARAM_TO_MODEL = {
      'dc:title'                    => 'title',
      'foaf:accountName'            => 'account_name',
      'foaf:accountServiceHomepage' => 'account_service_homepage'
  }.freeze

  # POST /person/:person_id/account(/:id)
  def create
    person = query_for_id(params[:person_id])
    
    attributes = {}
    PARAM_TO_MODEL.select { |f, _| account_params[f] }.each do |f, v|
      attributes[v] = account_params[f]
    end

    # Create person
    a = Lna::Account.create!(attributes) do |a|
      a.account_holder_id = person['id']
    end

    # Throw errors if not enough information
    @account = query_for_id(a.id)
    location = "/person/#{FedoraID.shorten(person['id'])}##{FedoraID.shorten(@account['id'])}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end


  # PUT /person/:person_id/account/:id
  def update
    account = query_for_account
    
    # update person's account
    attributes = {}
    PARAM_TO_MODEL.each do |f, v|
      attributes[v] = account_params[f] || ''
    end

    Lna::Account.find(params[:id]).update(attributes)
    
    # what should happen if update doesnt work

    @account = query_for_id(params[:id])
    
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /person/:person_id/account/:id
  def destroy
    account = query_for_account

    # Delete account.
    Lna::Account.find(account['id']).destroy

    # what to do if it doesnt work?

    respond_to do |f|
      f.jsonld { render json: '{ "status": "success" }', content_type: 'application/ld+json' }
    end
  end
  
  private

  def convert_to_full_fedora_id
    [:id, :person_id].each { |i| params[i] = FedoraID.lengthen(params[i]) }
  end

  def query_for_account
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Account'],
        ['id', params[:id]],
        ['account_ssim', params[:person_id]]
      ]
    )
    accounts = ActiveFedora::SolrService.query(query)
    (accounts.count == 1) ? accounts.first : not_found
  end
  
  def account_params
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
