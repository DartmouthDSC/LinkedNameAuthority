json.set! '@context' do
  json.dc RDF::Vocab::DC.to_s
  json.bibo RDF::Vocab::BIBO.to_s
end

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.partial! 'shared/success'
