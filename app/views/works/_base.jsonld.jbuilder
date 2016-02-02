json.partial! 'shared/context', vocabs: [:dc, :bibo]

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.partial! 'shared/success'
