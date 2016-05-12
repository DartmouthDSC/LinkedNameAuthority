class ChangeEventController < ApiController
  before_action :authenticate_user!, only: [:create, :terminate]

  # POST /organization/:id_from/change_to/:id_to
  def create
    load_organizations(:id_from, :id_to)

    logger.debug(create_params.inspect)
    date = Date.parse(create_params['prov:atTime'])

    description = create_params['dc:description']

    authorize! :create, Lna::Organization::ChangeEvent
    authorize! :create, Lna::Organization::Historic
    authorize! :update, @id_from
    authorize! :update, @id_to
    authorize! :destroy, @id_from
    
    event = Lna::Organization::ChangeEvent.trigger_event(
      @id_from, @id_to, description: description, date: date
    )
    
    @change_event = search_for_id(event.id)

    location = organization_path(FedoraID.shorten(@id_to.id)) + "##{FedoraID.shorten(event.id)}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
    end    
  end

  # POST /organization/:organization_id/end
  def terminate
    load_organizations(:organization_id)

    authorize! :destroy, @organization_id
    authorize! :create, Lna::Organization::Historic

    date = Date.parse(terminate_params['prov:atTime'])

    if @organization_id.is_a? Lna::Organization::Historic
      raise ActionController::BadRequest, 'organization already historic'
    end
    
    historic = Lna::Organization.convert_to_historic(@organization_id, date)

    @organization = search_for_id(historic.id)

    location = organization_path(FedoraID.shorten(historic.id))

    respond_to do |f|
      f.jsonld { render 'organization/create', status: :created, location: location,
                        content_type: 'application/ld+json' }
    end
  end

  def load_organizations(*org_keys)
    org_keys.each do |k|
      obj = ActiveFedora::Base.find(FedoraID.lengthen(params[k]))
      
      unless obj.is_a?(Lna::Organization) || obj.is_a?(Lna::Organization::Historic)
        raise ActionController::BadRequest, "#{k} must be an organization"
      end

      instance_variable_set("@#{k}", obj)
    end
  end


  def create_params
    params.require('dc:description')
    params.require('prov:atTime')
    params.permit('dc:description', 'prov:atTime') 
  end
  
  def terminate_params
    params.require('prov:atTime')
    params.permit('dc:description', 'prov:atTime')
  end
end
