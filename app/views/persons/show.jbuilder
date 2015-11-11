json.prettify!

json.set! '@graph', @person do |person|
  json.set! '@id', person['id']
  json.set! 'foaf:familyName', person['given_name_ssi']
end
