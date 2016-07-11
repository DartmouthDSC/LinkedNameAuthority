class AdminController < ApplicationController
  respond_to :html

  before_action :default_to_first_page, only: [:index, :search]

  def index
  end
  
  def default_to_first_page
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end
end
