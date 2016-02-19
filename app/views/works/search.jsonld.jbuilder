json.partial! 'works/base'

json.queryString URI.unescape(params.slice('bibo:authorList', 'bibo:doi', 'dc:title', 'dc:abstract', 'org:member').to_query)

json.partial! 'works/graph'
