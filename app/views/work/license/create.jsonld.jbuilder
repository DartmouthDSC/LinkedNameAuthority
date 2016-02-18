json.partial! 'shared/context', vocabs: [:ali, :dc]

json.set! '@id', work_license_url(work_id: FedoraID.shorten(params[:work_id]), id: FedoraID.shorten(@license['id']))

json.partial! 'work/license/license', license: @license

model = @license['has_model_ssim'].first
if model == Lna::Collection::FreeToRead.to_s
  description = "free_to_read"
elsif model == Lna::Collection::LicenseReference.to_s
  description = "license_ref"
end

json.set! 'dc:description', model
  
