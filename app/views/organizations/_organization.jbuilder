json.set! '@id', organization_path_url(id: simplify_fedora_id(org['id']))
json.set! '@type', 'org:Organization'
json.set! 'skos:prefLabel', org['label_tesim']
