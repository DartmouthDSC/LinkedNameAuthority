json.partial! 'organizations/base'

json.queryString URI.unescape(params.slice('org:identifier', 'skos:prefLabel', 'skos:altLabel', 'org:subOrganizationOf').to_query)

json.partial! 'organizations/graph', organizations: @organizations
