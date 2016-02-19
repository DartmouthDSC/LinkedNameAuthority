json.set! '@graph' do |json|
  json.array! organizations do |org|
    json.partial! 'organization/organization_minimal', org: org
    json.set! 'org:identifier', org['code_tesi'] || ''
    json.set! 'org:subOrganizationOf', org['subOrganizationOf_ssim'] || []
    json.set! 'skos:alt_label', org['alt_label_tesim'] || []
    json.set! 'owltime:hasBeginning', org['begin_date_dtsi']
    json.set! 'owltime:hasEnd', org['end_date_dtsi'] || ''
  end
end
