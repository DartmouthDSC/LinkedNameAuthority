json.partial! 'shared/context', vocabs: [:foaf, :org]

json.status "success"

json.partial! 'person/person', person: @person, full: true
json.set! 'foaf:name', @person['full_name_tesi'] || ''
json.set! 'foaf:mbox_sha1sum', @person['mbox_sha1sum_tesi'] || ''
