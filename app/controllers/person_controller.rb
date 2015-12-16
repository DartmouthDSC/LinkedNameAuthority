class PersonController < ApiController

  before_action :convert_to_full_fedora_id, except: :create
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  PARAM_TO_MODEL = {
      'foaf:name'       => 'full_name',
      'foaf:givenName'  => 'given_name',
      'foaf:familyName' => 'family_name',
      'foaf:title'      => 'title',
      'foaf:mbox'       => 'mbox',
      'foaf:image'      => 'image',
      'foaf:homepage'   => 'homepage'
  }.freeze
  
  # GET /person(/:id)
  def show
    @person = query_for_id(params[:id])
    
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Membership'],
        ['hasMember_ssim', @person['id']]
      ]
    )
    @memberships = ActiveFedora::SolrService.query(query)
    
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Account'],
        ['account_ssim', @person['id']]
      ]
    )
    @accounts = ActiveFedora::SolrService.query(query)

    # primary organization and all the membership's organizations
    org_ids = [ @person['reportsTo_ssim'].first ]
    @memberships.each do |m|
      org_ids << m['Organization_ssim'].first
    end

    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = ActiveFedora::SolrService.query(query)

    respond_to do |format|
      format.jsonld { render :show, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /person(/:id)
  def create
    name = params['foaf:name']

#    Lna::Person.create

    
    respond_to do |format|
      format.jsonld { render html: '{}', content_type: 'application/ld+json' }
    end
  end


  # PUT /person/:id

  # DELETE /person/:id
  
  # GET /person/:person_id/orcid
  def orcid
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Account'],
        ['account_ssim', params[:id]],
        ['title_tesi', 'ORCID']
      ]
    )
    @account = ActiveFedora::SolrService.query(query)

    not_found if @account.blank?
    
    respond_to do |format|
      format.jsonld { render :orcid, content_type: 'application/ld+json' }
    end
  end

  private

  def person_params
    params.permit(PARAM_TO_MODEL.keys)
  end
end
