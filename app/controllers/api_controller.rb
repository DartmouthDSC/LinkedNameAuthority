require 'fedora_id'
class ApiController < ActionController::Base
  # Adds additional behaviors into the application controller
#  include Hydra::Controller::ControllerBehavior
  include SolrSearchBehavior

  layout 'lna'
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  MAX_ROWS = 100.freeze
  
  # Because we are not using the database authenticatable module provided by
  # devise, we have to define this method so that controller can redirect in
  # case of failure.
  def new_session_path(scope)
    new_user_session_path
  end

  def after_sign_out_path_for(resource_or_scope)
#    request.referrer
    "https://login.dartmouth.edu/logout.php?app=LNA&url=#{root_url}"
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  private

  # Converts to id, person_id and work_id to full fedora ids if they are present.
  def convert_to_full_fedora_id
    [:id, :person_id, :work_id, :organization_id].each do |p|
      params[p] = FedoraID.lengthen(params[p]) if params[p].present?
    end
  end

  # Converts the parameter given to a full fedora id, if its a valid organization uri. If the
  # parameter is an array tries to convert all of the uris. This method is not responsible for
  # checking that the organization is present in the fedora store. If the uri is not a valid
  # organization uri the same uri is returned, unchanged.
  #
  # @private
  #
  # @param uri_param [String] param key containing uri
  # @return true if uri valid
  # @return false if uri id not valid
  def org_uri_to_fedora_id(uri_param)
    if uri = params[uri_param]
      if uri.kind_of? Array
        all_match = true
        new_uris = params[uri_param].map do |i|
          if match = org_path_matcher(i)
            match
          else
            all_match = false
          end
        end
        params[uri_param] = new_uris
        return all_match
      else
        if match = org_path_matcher(uri)
          params[uri_param] = match
          return true
        end
      end
    end
    return false
  end

  # see (#org_uri_to_fedora_id)
  # Throws error is uri is not valid.
  def org_uri_to_fedora_id!(uri_param)
    unless org_uri_to_fedora_id(uri_param)
      raise ActionDispatch::ParamsParser::ParseError.new("#{uri_param} must be a full uri", nil)
    end
  end

  def org_path_matcher(uri)
    if match = %r{^#{Regexp.escape(root_url)}organization/([a-zA-Z0-9-]+$)}.match(uri)
      FedoraID.lengthen(match[1])
    else
      return false
    end
  end
end
