json.set! '@id', '#' + event['id']
json.set! '@type', 'org:ChangeEvent'
json.set! 'org:originalOrganization', event['originalOrganization_ssim'] || []
json.set! 'org:resultingOrganization', event['resultingOrganization_ssim'] || []
json.set! 'prov:attime', event['at_time_ss']
json.set! 'dc:description', event['description_ss']
