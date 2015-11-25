class PersonController < ApiController

  before_action :full_fedora_id, except: :create
  before_action :authenticate_user!, only: [:create]

  # GET /person(/:person_id)
  def show
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids([params[:id]])
    @person = ActiveFedora::SolrService.query(query)

    not_found if @persons.blank?
    
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Membership'],
        ['hasMember_ssim', @person.first['id']]
      ]
    )
    @memberships = ActiveFedora::SolrService.query(query)
    
    query = ActiveFedora::SolrQueryBuilder.construct_query(
      [
        ['has_model_ssim', 'Lna::Account'],
        ['account_ssim', @person.first['id']]
      ]
    )
    @accounts = ActiveFedora::SolrService.query(query)
    respond_to do |format|
      format.jsonld { render :show, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /person
  def create
    respond_to do |format|
      format.jsonld { render '{}', content_type: 'application/ld+json' }
    end
  end

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

  def full_fedora_id
    if params[:id]
      /(?<first>^[a-zA-Z0-9]+)-/ =~ params[:id]
      params[:id] = first.scan(/[a-zA-Z0-9]{2}/).join('/') + '/' + params[:id]
    end
  end
end
