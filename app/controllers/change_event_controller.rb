class ChangeEventController < ApiController
  def create
    load_organizations(:id_from, :id_to)
        
    description = change_event_params('dc:description')
    date = Date.parse(change_event_params('prov:atTime'))

    authorize! :create, [Lna::Organization::ChangeEvent, Lna::Organiztion::Historic]
    authorize! :update, [@id_from, @id_to]
    authorize! :destroy, @id_from
    
    event = Lna::Organization::ChangeEvent.trigger_event(@id_from, @id_to,
                                                         description: description,
                                                         date: date)
  end

  def load_organizations(org_keys)
    org_keys.each do |k|
      value = ActiveFedora::Base.find(FedoraID.lengthen(params[k]))
      
      unless value.instance_of?(Lna::Organization) &&
             value.instance_of?(Lna::Organization::Historic)
        raise ActionController::BadRequest, "#{k} must be an organization"
      end

      instance_variable_set("@{k}", value)
    end
  end

  def change_event_params
    params.require('prov:atTime')
    params.require('dc:description')
  end
end
