json.prettify!

json.partial! 'organization/organization_minimal', org: org

json.set! 'org:identifier', org['hr_id_tesi'] || ''
json.set! 'skos:altLabel', org['alt_label_tesim'] || []
json.set! 'org:purpose', org['kind_tesi'] || ''
json.set! 'vcard:post-office-box', org['hinman_box_tesi'] || '' 
json.set! 'owltime:hasBeginning', org['begin_date_dtsi']
json.set! 'owltime:hasEnd', org['end_date_dtsi'] || ''


model = org['active_fedora_model_ssi']

if model == Lna::Organization.to_s
  super_orgs = org['subOrganizationOf_ssim']
  json.set! 'org:subOrganizationOf',
            (super_orgs) ? super_orgs.map{ |o| organization_url(id: FedoraID.shorten(o)) } : []
end

# For full organization records.
if full
  resulted_from = org['resultedFrom_ssim']
  json.set! 'org:resultedFrom', (resulted_from) ? '#' + FedoraID.shorten(resulted_from.first) : ''
  
  changed_by = org['changedBy_ssim']
  json.set! 'org:changedBy', (changed_by) ? '#' + FedoraID.shorten(changed_by.first) : ''

  case model
  when Lna::Organization.to_s
    sub_orgs = org['hasSubOrganization_ssim']
    json.set! 'org:hasSubOrganization',
              (sub_orgs) ? sub_orgs.map{ |o| organization_url(id: FedoraID.shorten(o)) } : []
  when Lna::Organization::Historic.to_s
    json.set! 'lna:historicPlacement', org['historic_placement_ss'] || ''
  end
end
  

