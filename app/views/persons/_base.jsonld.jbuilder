json.prettify!

json.partial! 'shared/context', vocabs: [:foaf, :dc, :skos]

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.status 'success'
