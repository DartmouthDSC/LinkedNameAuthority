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
end
