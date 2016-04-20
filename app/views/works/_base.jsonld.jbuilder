json.prettify!

json.partial! 'shared/context', vocabs: [:dc, :bibo]

json.set! '@id', url_for(params.slice(:action, :controller, :start_date, :page).merge(only_path: false))

json.partial! 'shared/generated_at'
json.partial! 'shared/success'
