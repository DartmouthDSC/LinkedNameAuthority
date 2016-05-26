json.prettify!

json.partial! 'shared/context', vocabs: [:bibo, :dc, :foaf]

person_id = FedoraID.shorten(@person['id'])

json.set! '@type', 'bibo:Collection'
json.set! '@id', person_works_url(person_id: person_id)
json.set! 'status', 'success'
json.set! 'foaf:primaryTopic', person_url(id: person_id)

has_parts = @works.map { |w| work_url(id: FedoraID.shorten(w['id']))}

json.set! 'bibo:hasPart', has_parts

json.set! '@graph' do
  json.array! @works do |work|
    json.partial! 'work/work', work: work, full: false
  end
end
