json.prettify!

json.partial! 'persons/context'

json.partial! 'shared/generated_at'

json.set! '@graph' do |json|
  json.array! @person do |person|
    json.partial! 'persons/person', person: person
    json.set! 'foaf:mbox', person['mbox_sha1sum_ssm'] || ''
    json.set! 'foaf:account' do
      json.array! @accounts do |account|
        json.set! '@id', '#' + simplify_fedora_id(account['id'])
      end
    end
  end

  json.array! @memberships do |membership|
    json.set! '@id', '#' + simplify_fedora_id(membership['id'])
    json.set! 'title', membership['title_tesim']
  end

  json.array! @accounts do |account|
    json.set! '@id', '#' + simplify_fedora_id(account['id'])
    json.set! 'dc:title', account['title_tesim']
  end
end
