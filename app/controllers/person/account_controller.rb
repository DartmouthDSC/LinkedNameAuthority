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

    # Create account.
    attributes = params_to_attributes(account_params, account_holder_id: person['id'])
    a = Lna::Account.new(attributes)
    render_unprocessable_entity && return unless a.save

    @account = search_for_id(a.id)
    location = "/person/#{FedoraID.shorten(person['id'])}##{FedoraID.shorten(@account['id'])}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
    end
  end

  # PUT /person/:person_id/account/:id
  def update
    account = search_for_accounts(id: params[:id], person_id: params[:person_id])
    
    # Update account.
    attributes = params_to_attributes(account_params, put: true)
    a = Lna::Account.find(params[:id])
    render_unprocessable_entity && return unless a.update(attributes)
    
    @account = search_for_id(params[:id])
    
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /person/:person_id/account/:id
  def destroy
    account = search_for_accounts(id: params[:id], person_id: params[:person_id])

    # Delete account.
    a = Lna::Account.find(account['id'])
    a.destroy
    render_unprocessable_entiry && return unless a.destroyed?

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
  
  def account_params
    params.permit(PARAM_TO_MODEL.keys << 'person_id')
  end
end
