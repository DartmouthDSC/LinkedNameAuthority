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

  private

  # Converts the uri given to a full fedora id, if its a valid organization uri. This
  # method is not responsible for checking that the organization is present in the fedora
  # store. If the uri is not a valid organization uri the same uri is returned, unchanged.
  def org_uri_to_fedora_id(uri)
    if uri
      if match = %r{^#{Regexp.escape(root_url)}organization/([a-zA-Z0-9-]+$)}.match(uri)
        params['org:organization'] = FedoraID.lengthen(match[1])
      else
        uri
      end
    end
  end
end
