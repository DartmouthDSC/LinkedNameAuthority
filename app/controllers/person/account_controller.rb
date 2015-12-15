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
    
    hash = {}
    PARAM_TO_MODEL.select { |f, _| account_params[f] }.each do |f, v|
      hash[v] = account_params[f]
    end

    # Create person
    a = Lna::Account.create!(hash) do |a|
      a.account_holder_id = params[:person_id]
    end

    # Throw errors if not enough information
    @account = query_for_id(a.id)
    
    respond_to do |format|
      format.jsonld { render :create, status: :created, content_type: 'application/ld+json' }
    end
  end


  # PUT /person/:person_id/account/:id
  def update
  end

  # DELETE /person/:person_id/account/:id
  def delete
  end
  
  private

  def convert_to_full_fedora_id
    [:id, :person_id].each { |i| full_fedora_id(i) }
  end
  
  def full_fedora_id(id_sym)
    if params[id_sym]
      /(?<first>^[a-zA-Z0-9]+)-/ =~ params[id_sym]
      if first
        params[id_sym] = first.scan(/[a-zA-Z0-9]{2}/).join('/') + '/' + params[id_sym]
      end
    end
  end

  def account_params
    params.permit('person_id', 'dc:title', 'foaf:accountName', 'foaf:accountServiceHomepage')
  end
end
