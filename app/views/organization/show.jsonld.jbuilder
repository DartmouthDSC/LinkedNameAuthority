json.prettify!

vocabs = [:org, :skos, :owltime, :foaf, :vcard]
vocabs.concat([:dc, :prov]) if @change_events

json.partial! 'shared/context', vocabs: vocabs
json.partial! 'shared/success'
json.set! 'foaf:primaryTopic', organization_url(FedoraID.shorten(@organization['id']))

json.set! '@graph' do 
  json.child! {
    json.partial! 'organization/organization', org: @organization, full: true

    if @organization['active_fedora_model_ssi'] == Lna::Organization.to_s
      json.set! 'foaf:account',
                (@accounts) ? @accounts.map { |a| '#' + FedoraID.shorten(a['id']) } : []
    end
    
  }

  json.array! @related_orgs do |org|
    json.partial! 'organization/organization', org: org, full: false
  end

  json.array! @accounts do |account|
    json.partial! 'account/account', account: account
  end
                            
  json.array! @change_events do |event|
    json.partial! 'change_event/change_event', event: event
  end
end
