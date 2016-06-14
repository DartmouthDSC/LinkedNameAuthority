
# If full parameter is true, more fields are displayed.

json.set! '@id', person_url(id: FedoraID.shorten(person['id']))
json.set! '@type', 'foaf:Person'
json.set! 'foaf:name', person['full_name_tesi']
json.set! 'foaf:givenName', person['given_name_tesi']
json.set! 'foaf:familyName', person['family_name_tesi']
json.set! 'foaf:title', person['title_ss'] || ''
json.set! 'foaf:mbox', person['mbox_ss'] || ''

if full
  json.set! 'foaf:mbox_sha1sim', person['mbox_sha1sum_tesi'] || ''
end

json.set! 'foaf:image', person['image_ss'] || ''

if full
  json.set! 'foaf:homepage', person['homepage_tesim'] || []
end

json.set! 'org:reportsTo', organization_url(FedoraID.shorten(person['reportsTo_ssim'].first))
  
