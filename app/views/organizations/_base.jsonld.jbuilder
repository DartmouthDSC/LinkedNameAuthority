json.prettify!

json.partial! 'shared/context', vocabs: [:org, :owltime, :skos]

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.partial! 'shared/success'
