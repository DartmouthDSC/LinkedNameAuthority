class Work::LicenseController < Api::Controller
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :convert_to_full_fedora_id

  PARAM_TO_MODEL = {
    'ali:start_date' => 'start_date',
    'ali:end_date'   => 'end_date',
    'ali:uri'        => 'license_uri',
    'dc:title'       => 'title'
  }
  
  # POST /work/:work_id/license
  def create
    work = search_for_works(id: params['work_id'])

    attributes = params_to_attributes(license_params, document_id: work['id'])

    case license_params['dc:description']
    when 'license_ref'
      l = Lna::Collection::LicenseReference.new(attributes)
    when 'free_to_read'
      l = Lna::Collection::FreeToRead.new(attributes)
    else
      render_unprocessable_entity && return
    end

    render_unprocessable_entity && return unless l.save

    @license = search_for_id(license.id)
    
    location = "/work/#{FedoraId.shorten(work['id'])}##{FedoraId.shorten(@license['id'])}"
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json'}
    end
  end

  # PUT /work/:work_id/license/:id
  def update
    license = search_for_licenses(id: params[:id], document_id: params[:work_id])

    # Update license.
    attributes = params_to_attributes(license_params, put: true, document_id: params[:work_id])
    l = ActiveFedora::Base.find(license['id'])
    render_unprocessable_entity && return unless l.update(attributes)

    @license = search_for_id(params[:id])

    response_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /work/:work_id/license/:id
  def destroy
    license = search_for_licenses(id: params[:id], document_id: params[:work_id])

    # Delete License
    l = ActiveFedora::Base.find(license['id'])
    l.destroy
    render_unprocessable_entiry && return unless l.destroyed?

    respond_to do |f|
      f.jsonld { render json: '{ "status": "success" }', content_type: 'application/ld+json' }
    end
  end

  def license_params
    params.permit(PARAM_TO_MODEL.keys + ['id', 'work_id'])
  end
end
