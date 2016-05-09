class Admin::PersonsController < AdminController
  # GET /persons
  def index
    @page = params['page']
  end

  # POST /persons
  def search
  end
end
