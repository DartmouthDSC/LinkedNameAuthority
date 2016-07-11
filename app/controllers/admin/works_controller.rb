class Admin::WorksController < AdminController
  # GET /works
  def index
    @page = params['page']
  end

  # POST /works
  def search
  end
end
