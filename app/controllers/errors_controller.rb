class ErrorsController < ApplicationController
  include Gaffe::Errors

  layout 'lna'
  
  skip_before_action :verify_authenticity_token

  def show
    render "errors/errors", status: @status_code
  rescue ActionView::MissingTemplate
    render 'errors/internal_server_error', status: 500
  end
end
