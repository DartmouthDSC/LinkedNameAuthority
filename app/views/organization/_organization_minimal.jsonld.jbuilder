json.set! '@id', organization_url(id: FedoraID.shorten(org['id']))
json.set! '@type', 'org:Organization'
json.set! 'skos:prefLabel', org['label_tesi']
