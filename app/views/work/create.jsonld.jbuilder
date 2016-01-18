json.set! "@context" do
  json.bibo 'http://purl.org/ontology/bibo/#'
  json.dc 'http://purl.org/dc/elements/1.1/'
end

json.status 'success'

json.partial! 'work/work', work: @work, full: true
