json.set! '@id', '#' + FedoraID.shorten(event['id'])
json.set! '@type', 'org:ChangeEvent'

json.set! 'org:originalOrganization', org_ids_to_uri(event['originalOrganization_ssim'])
json.set! 'org:resultingOrganization', org_ids_to_uri(event['resultingOrganization_ssim'])
json.set! 'prov:attime', event['at_time_ss']
json.set! 'dc:description', event['description_ss']
