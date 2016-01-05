json.set! "@context" do
  json.foaf "http://xmlns.com/foaf/0.1/"
  json.org "http://www.w3.org/ns/org#"
end

json.status "success"

json.partial! 'person/person', person: @person
json.set! 'foaf:name', @person['full_name_tesi'] || ''
json.set! 'foaf:mbox_sha1sum', @person['mbox_sha1sum_tesi'] || ''
