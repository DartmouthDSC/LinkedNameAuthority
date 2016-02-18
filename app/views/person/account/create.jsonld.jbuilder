
json.partial! 'shared/context', vocabs: [:foaf, :dc]

json.set! 'status', 'success'

json.partial! '/person/account/account', account: @account,
              id: person_account_url(person_id: FedoraID.shorten(params[:person_id]),
                                     id: FedoraID.shorten(@account['id']))
