json.partial! 'shared/context', vocabs: [:skos, :org, :owltime, :vcard]

json.partial! 'shared/success'

json.partial! 'organization/organization', org: @organization, full: false

