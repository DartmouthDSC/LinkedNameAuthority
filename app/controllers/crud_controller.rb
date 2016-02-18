class CrudController < ApiController
  before_action :convert_to_full_fedora_id
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  # GET
  def show
    respond_to do |f|
      f.jsonld { render :show, content_type: 'application/ld+json' }
      f.html
    end
  end

  # PUT
  def update
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end
  
  # DELETE
  def destroy
    respond_to do |f|
      f.jsonld { render json: '{"status": "success"}', content_type: 'application/ld+json' }
    end
  end
end
