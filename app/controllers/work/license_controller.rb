class Work::LicenseController < CrudController
  LICENSE_REF  = 'license_ref'
  FREE_TO_READ = 'free_to_read'
  PARAM_TO_MODEL = {
    'ali:start_date' => 'start_date',
    'ali:end_date'   => 'end_date',
    'ali:uri'        => 'license_uri',
    'dc:title'       => 'title'
  }
  
  # POST /work/:work_id/license
  def create
    authorize! :create, Lna::Collection::LicenseReference
    authorize! :create, Lna::Collection::FreeToRead
    
    work = search_for_works(id: license_params[:work_id])

    case license_params['dc:description']
    when LICENSE_REF
      l = Lna::Collection::LicenseReference.new(attributes)
    when FREE_TO_READ
      l = Lna::Collection::FreeToRead.new(attributes)
    else
      raise ActiveFedora::RecordInvalid, ActiveFedora::Base.new,
            'dc:description must be license_ref or free_to_read'
    end

    l.save!

    @license = search_for_id(l.id)
    
    location = "/work/#{FedoraID.shorten(work['id'])}##{FedoraID.shorten(@license['id'])}"

    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
      f.html {redirect_to work_path(FedoraID.shorten(work['id'])) }
    end
  end

  # PUT /work/:work_id/license/:id
  def update
    license = search_for_licenses(id: params[:id], document_id: params[:work_id])

    # Update license.
    l = ActiveFedora::Base.find(license['id'])
    authorize! :update, l
    l.update(attributes)
    l.save!

    @license = search_for_id(params[:id])

    super
  end

  # DELETE /work/:work_id/license/:id
  def destroy
    license = search_for_licenses(id: params[:id], document_id: params[:work_id])

    # Delete License
    l = ActiveFedora::Base.find(license['id'])
    authorize! :destroy, l
    l.destroy!

    super
  end

  def attributes
    params_to_attributes(license_params, document_id: params[:work_id])
  end

  def license_params
    params.require('dc:description')
    params.require('ali:start_date')
    params.require('dc:title')
    params.require('ali:uri') if params['dc:description'] == LICENSE_REF
    params.permit(PARAM_TO_MODEL.keys.concat(['id', 'work_id', 'dc:description']))
  end
end
