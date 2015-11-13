json.prettify!

json.partial! 'persons/context'
json.set! "@context" do
  if @memberships
    json.set! "vcard", "http://www.w3.org/2006/vcard/ns#"
    json.set! "owltime", "http://www.w3.org/TR/owl-time#"
  end
  if @accounts
    json.set! "dc", "http://purl.org/dc/elements/1.1/"
  end
end

json.set! 'skos:primarySubject' do
  json.child! { json.set! '@id', request.original_url }
end

json.partial! 'shared/generated_at'
json.status 'success'

json.set! '@graph' do |json|
  json.array! @person do |person|
    json.partial! 'persons/person', person: person

    json.set! 'foaf:account' do
      json.array! @accounts do |account|
        json.set! '@id', '#' + simplify_fedora_id(account['id'])
      end
    end
  end

  json.array! @memberships do |membership|
    json.partial! 'persons/membership', membership: membership
  end

  json.array! @accounts do |account|
    json.partial! 'persons/account', account: account
  end
end
