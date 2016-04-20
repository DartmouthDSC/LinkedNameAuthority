json.set! '@graph' do |json|
  json.array! organizations do |org|
    json.partial! 'organization/organization', org: org, full: false
  end
end
