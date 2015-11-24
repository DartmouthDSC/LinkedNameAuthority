json.set! '@id', '#' + simplify_fedora_id(membership['id'])
json.set! 'org:organization', membership['Organization_ssim'].first
json.set! 'vcard:email', membership['email_ss'] || ''
json.set! 'vcard:title', membership['title_tesi']
json.set! 'vcard:street-address', membership['street_address_ss'] || ''
json.set! 'vcard:postal-code', membership['postal_code_ss'] || ''
json.set! 'vcard:country-name', membership['country_name_ss'] || ''
json.set! 'vcard:locality', membership['locality_ss'] || ''
json.set! 'owltime:hasBeginning', membership['begin_date_dtsi']
json.set! 'owltime:hasEnd', membership['end_date_dtsi'] || ''

