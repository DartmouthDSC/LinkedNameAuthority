require 'fedora_id'

class ApiController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Hydra::Controller::ControllerBehavior

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  rescue_from ActionController::RoutingError, with: :render_not_found
  
  # Because we are not using the database authenticatable module provided by
  # devise, we have to define this method so that controller can redirect in
  # case of failure.
  def new_session_path(scope)
    new_user_session_path
  end

  def after_sign_out_path_for(resource_or_scope)
    "https://login.dartmouth.edu/logout.php?app=#{I18n.t 'blacklight.application_name'}&url=#{root_url}"
  end

  # TODO: Need to revist this.
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def render_not_found
    respond_to do |f|
      f.jsonld { render json: { error: 'not_found' }.to_json, status: :not_found,
                        content_type: 'application/ld+json' }
    end
  end
  
  def default_to_first_page
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end

  def convert_to_full_fedora_id
    params[:id] = FedoraID.lengthen(params[:id])
  end
  
  def link_headers(namespace, page, max_rows, solr_params)
    previous_page = (page == 1) ? nil : page - 1;
    new_page = page + 1
    solr_params[:start] = new_page * max_rows
    next_page = new_page if query(solr_params).count > 0
    
    url_prefix = root_url + namespace

    links = ["<#{url_prefix}1>; ref=\"first\""]
    links << "<#{url_prefix}#{previous_page}>; ref=\"prev\"" if previous_page
    links << "<#{url_prefix}#{next_page}>; ref=\"next\"" if next_page
    links.join(', ')
  end

  def query(params)
    logger.debug("Solr params: #{params.to_s}")
    ActiveFedora::SolrService.query(params[:q], params)
  end

  def query_for_id!(id)
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids([id])
    results = ActiveFedora::SolrService.query(query)

    case results.count
    when 1
      results.first
    when 0
      raise_error 'No results for the id given.'
    else
      raise_error 'More than one result for the id given.'
    end
  end

  def query_for_id(id)
    begin
      query_for_id!(id)
    rescue
      not_found
    end
  end
end
