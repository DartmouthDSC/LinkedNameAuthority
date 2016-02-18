json.prettify!

vocabs = [:org, :skos, :owltime, :foaf]
vocabs.concat([:dc, :prov]) if @change_events

json.partial! 'shared/context', vocabs: vocabs
json.partial! 'shared/success'
json.set! 'foaf:primaryTopic', request.original_url

json.set! '@graph' do 
  json.child! {
    json.partial! 'organization/organization', org: @organization, full: true, accounts: @accounts
  }

  json.array! @related_orgs do |org|
    json.partial! 'organization/organization', org: org, full: false
  end

  json.array! @accounts do |account|
    json.partial! 'person/account/account', account: account
  end
                            
  json.array! @change_events do |event|
    json.partial! 'organization/change_event', event: event
  end
end
