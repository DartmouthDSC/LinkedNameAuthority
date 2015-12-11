class ApiController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Hydra::Controller::ControllerBehavior

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Because we are not using the database authenticatable module provided by
  # devise, we have to define this method so that controller can redirect in
  # case of failure.
  def new_session_path(scope)
    new_user_session_path
  end

  def after_sign_out_path_for(resource_or_scope)
    "https://login.dartmouth.edu/logout.php?app=#{I18n.t 'blacklight.application_name'}&url=#{root_url}"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private
  
  def page_default_to_first
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end
end
