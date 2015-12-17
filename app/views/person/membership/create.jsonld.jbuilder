
json.set! "@context" do 
  json.org "http://www.w3.org/ns/org#"
  json.vcard "http://www.w3.org/2006/vcard/ns#"
  json.owltime "http://www.w3.org/TR/owl-time#"
end

json.status 'success'

json.partial! 'person/membership/membership', membership: @membership, id: "#{root_url}person/#{FedoraID.shorten(params[:person_id])}/membership/#{FedoraID.shorten(@membership['id'])}"
