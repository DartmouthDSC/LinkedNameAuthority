
vocab_uri = {
  dc: RDF::Vocab::DC.to_s,
  foaf: RDF::Vocab::FOAF.to_s,
  skos: RDF::Vocab::SKOS.to_s,
  org: RDF::Vocab::ORG.to_s,
  owltime: Vocabs::OwlTime.to_s,
  bibo: RDF::Vocab::BIBO.to_s,
  vcard: RDF::Vocab::VCARD.to_s,
  ali: Vocabs::ALI.to_s
}

json.set! '@context' do
  vocabs.each do |v|
    if vocab_uri.key?(v)
      json.set! v.to_s, vocab_uri[v]
    end
  end
end
