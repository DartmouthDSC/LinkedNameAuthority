json.prettify!

vocabs = [:foaf, :dc, :skos]
vocabs = vocabs + [:vcard, :owltime] if @memberships
vocabs << :id if @accounts
json.partial! 'shared/context', vocabs: vocabs

json.set! 'skos:primarySubject' do
  json.child! { json.set! '@id', request.original_url }
end

json.partial! 'shared/generated_at'
json.status 'success'

json.set! '@graph' do

  json.child! { json.partial! 'person/person', person: @person, full: true }

  json.child! {
    json.set! 'foaf:account' do
      json.array! @accounts do |account|
        json.set! '@id', '#' + FedoraID.shorten(account['id'])
      end
    end
  }

  json.array! @memberships do |membership|
    json.partial! 'person/membership/membership', membership: membership, id: "##{FedoraID.shorten(membership['id'])}"
  end

  json.array! @accounts do |account|
    json.partial! 'person/account/account', account: account, id: nil
  end

  json.array! @organizations do |organization|
    json.partial! 'organization/organization', org: organization
  end
end
