json.set! '@graph' do |json|
  json.array! @persons do |person|
    json.partial! 'person/person', person: person, full: false
  end
  json.array! @organizations do |org|
    json.partial! 'organization/organization', org: org
  end
end
