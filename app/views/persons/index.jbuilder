json.prettify!

json.partial! 'persons/context'

json.set! '@id', "#{request.original_url}"
json.partial! 'shared/generated_at'
json.status 'success'

json.set! '@graph' do |json|
  json.array! @persons do |person|
    json.partial! 'persons/person', person: person
  end
  json.array! @organizations do |org|
    json.partial! 'organizations/organization', org: org
  end
end
