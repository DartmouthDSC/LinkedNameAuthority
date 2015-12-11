json.prettify!

json.partial! 'organizations/context'

json.set! '@id', request.original_url
json.partial! 'shared/generated_at'
json.status 'success'

json.set! '@graph' do |json|
  json.array! @organizations do |org|
    json.partial! 'organization/organization', org: org
    json.set! 'org:identifier', org['code_tesi']
#    json.set! 'org:subOrganizationOf', 
    json.set! 'skos:alt_label', org['alt_label_tesim'] || []
    json.set! 'owltime:hasBeginning', org['begin_date_dtsi'] 
  end
end
