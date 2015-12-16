json.set! "@context" do
  json.foaf "http://xmlns.com/foaf/0.1/"
  json.dc "http://purl.org/dc/elements/1.1/"
end

json.set! 'status', 'success'

json.partial! '/person/account', account: @account,
              id: "#{root_url}person/#{FedoraID.shorten(params[:person_id])}/account/#{FedoraID.shorten(@account['account_ssim'].first)}"
