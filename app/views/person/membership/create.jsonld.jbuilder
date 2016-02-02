
json.partial! 'shared/context', vocabs: [:org, :vcard, :owltime]

json.status 'success'

json.partial! 'person/membership/membership', membership: @membership, id: "#{root_url}person/#{FedoraID.shorten(params[:person_id])}/membership/#{FedoraID.shorten(@membership['id'])}"
