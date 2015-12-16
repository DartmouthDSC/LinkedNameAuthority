
json.set! '@id', person_url(id: FedoraID.shorten(person['id']))
json.set! '@type', 'foaf:Person'
json.set! 'foaf:givenName', person['given_name_ssi']
json.set! 'foaf:familyName', person['family_name_ssi']
json.set! 'foaf:title', person['title_ss'] || ''
json.set! 'foaf:mbox', person['mbox_ss']
json.set! 'foaf:image', person['image_ss'] || ''
json.set! 'org:reportsTo', root_url + 'organization/' + FedoraID.shorten(person['reportsTo_ssim'].first)
  
