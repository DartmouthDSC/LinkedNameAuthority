json.prettify!

json.partial! 'persons/context'

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.status 'success'
