json.prettify!

json.partial! 'shared/context', vocabs: [:org, :owltime, :skos, :vcard]

json.set! '@id', url_for(params.slice(:action, :controller, :page).merge(only_path: false))
json.partial! 'shared/generated_at'
json.partial! 'shared/success'
