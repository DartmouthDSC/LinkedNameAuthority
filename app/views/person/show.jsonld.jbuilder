json.prettify!

vocabs = [:foaf, :skos]
vocabs.concat([:vcard, :owltime]) if @memberships
vocabs << :dc unless @accounts.empty?
json.partial! 'shared/context', vocabs: vocabs

json.set! 'foaf:primaryTopic', person_url(FedoraID.shorten(@person['id']))

json.partial! 'shared/generated_at'
json.partial! 'shared/success'

json.set! '@graph' do
  json.child! {
    json.partial! 'person/person', person: @person, full: true
    json.set! 'foaf:publications', person_works_url(person_id: FedoraID.shorten(@person['id']))
    json.set! '@reverse' do
      json.set! 'org:member' do
        json.array! @memberships do |membership|
          json.set! '@id', '#' + FedoraID.shorten(membership['id'])
        end
      end
    end
    json.set! 'foaf:account' do
      json.array! @accounts do |account|
        json.set! '@id', '#' + FedoraID.shorten(account['id'])
      end
    end
   
  }

  json.array! @memberships do |membership|
    json.partial! 'person/membership/membership', membership: membership
  end

  json.array! @accounts do |account|
    json.partial! 'account/account', account: account
  end

  json.array! @organizations do |organization|
    json.partial! 'organization/organization_minimal', org: organization
  end
end
