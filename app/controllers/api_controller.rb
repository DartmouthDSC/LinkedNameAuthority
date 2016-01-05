require 'fedora_id'
class ApiController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Hydra::Controller::ControllerBehavior
  include SolrSearchBehavior
  
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
    next_page = new_page if solr_search(solr_params).count > 0
    
    url_prefix = root_url + namespace

    links = ["<#{url_prefix}1>; ref=\"first\""]
    links << "<#{url_prefix}#{previous_page}>; ref=\"prev\"" if previous_page
    links << "<#{url_prefix}#{next_page}>; ref=\"next\"" if next_page
    links.join(', ')
  end

  # Converts the uri given to a full fedora id, if its a valid organization uri.
  # This method is not responsible for checking that the organization is valid.
  # If the uri is not a valid organization uri the same uri is returned, unchanged.
  def org_uri_to_fedora_id(uri)
    if uri
      if match = %r{^#{Regexp.escape(root_url)}organization/([a-zA-Z0-9-]+$)}.match(uri)
        params['org:organization'] = FedoraID.lengthen(match[1])
      else
        uri
      end
    end
  end
end
