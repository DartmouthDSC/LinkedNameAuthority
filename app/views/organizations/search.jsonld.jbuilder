json.partial! 'organizations/base'

json.queryString URI.unescape(params.slice('org:identifier', 'skos:pref_label', 'skos:alt_label', 'org:subOrganizationOf').to_query)

json.partial! 'organizations/graph', organizations: @organizations
