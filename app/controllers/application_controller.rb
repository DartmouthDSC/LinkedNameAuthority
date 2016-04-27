class ApplicationController < ActionController::Base
  # before_filter do
  #   resource = controller_path.singularize.gsub('/', '_').to_sym 
  #   method = "#{resource}_params"
  #   params[resource] &&= send(method) if respond_to?(method, true)
  # end

#  include Hydra::Controller::ControllerBehavior
  layout 'lna'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Because we are not using the database authenticatable module provided by
  # devise, we have to define this method so that controller can redirect in
  # case of failure.
  def new_session_path(scope)
    new_user_session_path
  end

  def index
  end

  def after_sign_out_path_for(resource_or_scope)
    "https://login.dartmouth.edu/logout.php?app=LNA&url=#{root_url}"
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
end
