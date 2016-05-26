json.set! '@id', organization_url(FedoraID.shorten(org['id']))
json.set! '@type', 'org:Organization'
json.set! 'skos:prefLabel', org['label_tesi']
