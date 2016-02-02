
json.partial! 'shared/context', vocabs: [:foaf, :dc]

json.set! 'status', 'success'

json.partial! '/person/account/account', account: @account,
              id: "#{root_url}person/#{FedoraID.shorten(params[:person_id])}/account/#{FedoraID.shorten(@account['id'])}"
