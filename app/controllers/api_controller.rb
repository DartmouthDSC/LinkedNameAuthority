require 'fedora_id'
class ApiController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Hydra::Controller::ControllerBehavior
  include SolrSearchBehavior

  layout 'lna'
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  rescue_from ActionController::RoutingError, with: :render_not_found

  MAX_ROWS = 100.freeze
  
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
      f.jsonld { render json: { status: 'failure', error: 'not_found' }.to_json,
                        status: :not_found, content_type: 'application/ld+json' }
    end
  end

  # Error message for when an update, create or delete is unsuccessful.
  # TODO: Error message should be more detailed put it would require mapping the errors
  # back to the keys that the user knows about. How exactly we want this to look like should
  # be decided on before we move in that direction.
  def render_unprocessable_entity
    respond_to do |f|
      f.jsonld { render json: { status: 'failure',
                                error: 'Problem creating, updating or deleting record'}.to_json,
                        status: :unprocessable_entity,
                        content_type: 'application/ld+json' }
    end
  end
  
  def default_to_first_page
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end

  # Converts to id, person_id and work_id to full fedora ids if they are present.
  def convert_to_full_fedora_id
    [:id, :person_id, :work_id, :organization_id].each do |p|
      params[p] = FedoraID.lengthen(params[p]) if params[p].present?
    end
  end
  
  def link_headers(namespace, page, next_page)
    previous_page = (page == 1) ? nil : page - 1;
    
    url_prefix = root_url + namespace

    links = ["<#{url_prefix}1>; ref=\"first\""]
    links << "<#{url_prefix}#{previous_page}>; ref=\"prev\"" if previous_page
    links << "<#{url_prefix}#{page + 1}>; ref=\"next\"" if next_page
    links.join(', ')
  end

  # Helper method to map parameters send in request of body to model attributes.
  #
  # @private
  #
  # @params params [Hash] parameters passed in by user
  # @params put [boolean] true if used for a put request; all fields are required to contain an
  #   empty string even if they aren't set.
  # @params extra_params [Hash]
  def params_to_attributes(params, put: false, **extra_params)
    attributes = {}
    attributes.merge!(extra_params) if extra_params
    
    self.class::PARAM_TO_MODEL.each do |f, v|
      if put && !params[f]
        attributes[v] = ''
      elsif params[f]
        attributes[v] = params[f]
      end
    end
    attributes
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
