
json.partial! 'shared/context', vocabs: [:foaf, :dc]

json.set! 'status', 'success'


account_id = FedoraID.shorten(@account['id'])
if @request_path == 'person'
  id = person_account_url(person_id: FedoraID.shorten(params[:person_id]), id: account_id)
else
  id = organization_account_url(organization_id: FedoraID.shorten(params[:organization_id]),
                                id: account_id)
end


json.partial! '/account/account', account: @account, id: id
