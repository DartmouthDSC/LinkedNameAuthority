json.prettify!

json.set! '@context' do
  json.foaf 'http://xmlns.com/foaf/0.1/'
  json.org 'http://www.w3.org/ns/org#'
  json.skos 'http://www.w3.org/2004/02/skos/core#'
end

json.set! '@id', "#{request.original_url}"
json.generatedAt Time.now.strftime("%FT%TZ")
json.status 'success'

json.set! '@graph',  @persons do |person|
  json.set! '@id', simplify_fedora_id(person['id'])
  json.set! '@type', 'foaf:Person'
  json.set! 'foaf:givenName', person['given_name_ssi'] 
  json.set! 'foaf:familyName', person['family_name_ssi']
  json.set! 'foaf:name', person['full_name_tsi']
  json.set! 'foaf:title', person['title'] || ''
  json.set! 'foaf:mbox', person['mbox_ss']
  json.set! 'foaf:image', person['image_ssm'] || ''
  json.set! 'org:reportsTo', root_url + 'organization/' + simplify_fedora_id(person['reportsTo_ssim'].first)
end
