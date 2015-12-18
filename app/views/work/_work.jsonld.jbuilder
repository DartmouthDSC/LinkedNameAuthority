json.set! '@type', 'bibo:Document'
json.set! '@id', "#{root_url}work/#{FedoraID.shorten(work['id'])}"
json.set! 'bibo:doi', work['doi_tesi'] || ''
json.set! 'bibo:uri', work['canonical_uri_ssm'] || ''
json.set! 'bibo:volume', work['volume_ss'] || ''
json.set! 'bibo:pages', work['pages_ss'] || ''
json.set! 'bibo:pageStart', work['page_start_ss'] || ''
json.set! 'bibo:authorsList', work['author_list_ss'] || ''
json.set! 'dc:title', work['title_tesi']
json.set! 'dc:abstract', work['abstract_ss'] || ''
json.set! 'dc:publisher', work['publisher_ss'] || ''
json.set! 'dc:date', work['date_dtsi'] || ''
json.set! 'dc:creator', "#{root_url}person/#{FedoraID.shorten(person['id'])}"
