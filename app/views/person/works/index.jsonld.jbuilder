json.prettify!

json.partial! 'shared/context', vocabs: [:bibo, :dc, :foaf]

person_id = FedoraID.shorten(@person['id'])

json.set! '@type', 'bibo:Collection'
json.set! '@id', "#{root_url}person/#{person_id}/works"
json.set! 'status', 'success'
json.set! 'foaf:primaryTopic', "#{root_url}person/#{person_id}"

has_parts = @works.map { |w| "#{root_url}work/#{FedoraID.shorten(w['id'])}/" }

json.set! 'bibo:hasPart', has_parts

json.set! '@graph' do
  json.array! @works do |work|
    json.partial! 'work/work', work: work, full: false
  end
end
