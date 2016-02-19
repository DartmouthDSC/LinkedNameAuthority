json.prettify!

json.partial! 'organization/organization_minimal', org: org
json.set! 'org:identifier', org['code_tesi'] || ''

json.set! 'skos:altLabel', org['alt_label_tesim'] || []
json.set! 'owltime:hasBeginning', org['begin_date_dtsi']
json.set! 'owltime:hasEnd', org['end_date_dtsi'] || ''

if full
  resulted_from = org['resultedFrom_ssim']
  json.set! 'org:resultedFrom', (resulted_from) ? '#' + FedoraID.shorten(resulted_from) : ''
  
  change_by = org['changeBy_ssim']
  json.set! 'org:changedBy', (change_by) ? '#' + FedoraID.shorten(change_by) : ''
end

if org['active_fedora_model_ssi'] == Lna::Organization.to_s
  super_orgs = org['subOrganizationOf_ssim']
  json.set! 'org:subOrganizationOf',
            (super_orgs) ? super_orgs.map{ |o| organization_url(id: FedoraID.shorten(o))} : []
  if full
    sub_orgs = org['hasSubOrganization_ssim'] 
    json.set! 'org:hasSubOrganization',
              (sub_orgs) ? sub_orgs.map{ |o| organization_url(id: FedoraID.shorten(o)) } : []
    
    json.set! 'foaf:account',
              (accounts) ? accounts.map { |a| '#' + FedoraID.shorten(a['id']) } : []
  end
end
