json.prettify!

json.partial! 'persons/context'

json.partial! 'shared/generated_at'

json.set! '@graph' do |json|
  json.array! @person do |person|
    json.partial! 'persons/person', person: person
    json.set! 'foaf:mbox', person['mbox_sha1sum_ssm'] || ''
  end

  json.array! @memberships do |membership|
    json.set! 'title', person['title_tesim']
  end
end
