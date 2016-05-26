json.partial! 'persons/base'

json.queryString URI.unescape(params.slice('foaf:name', 'foaf:givenName', 'foaf:familyName', 'org:member').to_query)

json.partial! 'persons/graph'

