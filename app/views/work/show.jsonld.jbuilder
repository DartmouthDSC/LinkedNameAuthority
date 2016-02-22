json.partial! 'shared/context', vocabs: [:bibo, :dc, :foaf, :ali]
json.set! '@type', 'bibo:Document'
json.partial! 'shared/success'
json.set! 'foaf:primaryTopic', request.original_url

free_to_read_ids = []; license_ref_ids = []

@licenses.each do |license|
  case license['has_model_ssim'].first
  when Lna::Collection::LicenseReference.to_s
    license_ref_ids << "##{FedoraID.shorten(license['id'])}"
  when Lna::Collection::FreeToRead.to_s
    free_to_read_ids << "##{FedoraID.shorten(license['id'])}"
  end
end

json.set! '@graph' do
  json.child! {
    json.partial! 'work/work', work: @work, full: true
    json.set! 'ali:license_ref', license_ref_ids
    json.set! 'ali:free_to_read', free_to_read_ids    
  }

  json.child! { json.partial! 'person/person', person: @person, full: false }
  
  json.array! @licenses do |license|
    json.set! '@id', "##{FedoraID.shorten(license['id'])}"
    json.partial! 'work/license/license', license: license
  end
end




