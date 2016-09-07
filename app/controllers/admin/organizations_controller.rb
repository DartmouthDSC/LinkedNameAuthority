class Admin::OrganizationsController < AdminController
  # GET /organizations
  def index
    @page = params['page']
  end

  # POST /organizations
  def search
  end
end
