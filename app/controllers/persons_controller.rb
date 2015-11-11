class PersonsController < ActionController::Base
  include Hydra::Controller::ControllerBehavior

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :full_fedora_id, except: :index
  
  ROWS = 100.freeze
  
  def index
    page = params['page'].to_i
    args =
      {
        rows: ROWS,
        sort: 'family_name_ssi asc, given_name_ssi asc',
        fq: 'has_model_ssim:"Lna::Person"'
      }
    args[:start] = page * ROWS if page > 1
    
    @persons = ActiveFedora::SolrService.query("*:*", args)
  end

  def show
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids([params[:id]])
    @person = ActiveFedora::SolrService.query(query)
  end

  private

  def full_fedora_id
    if params[:id]
      /(?<first>^[a-zA-Z0-9]+)-/ =~ params[:id]
      params[:id] = first.scan(/[a-zA-Z0-9]{2}/).join('/') + '/' + params[:id]
    end
  end
end
