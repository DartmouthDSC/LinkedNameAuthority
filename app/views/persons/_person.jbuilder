
json.set! '@id', person_path_url(id: simplify_fedora_id(person['id']))
json.set! '@type', 'foaf:Person'
json.set! 'foaf:givenName', person['given_name_ssi']
json.set! 'foaf:familyName', person['family_name_ssi']
json.set! 'foaf:title', person['title'] || ''
json.set! 'foaf:mbox', person['mbox_ss']
json.set! 'foaf:image', person['image_ssm'] || ''
json.set! 'org:reportsTo', root_url + 'organization/' + simplify_fedora_id(person['reportsTo_ssim'].first)
  
