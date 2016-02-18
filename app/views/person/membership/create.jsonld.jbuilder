
json.partial! 'shared/context', vocabs: [:org, :vcard, :owltime]

json.status 'success'

json.partial! 'person/membership/membership',
              membership: @membership,
              id: person_membership_url(person_id: FedoraID.shorten(params[:person_id]),
                                        id: FedoraID.shorten(@membership['id']))
