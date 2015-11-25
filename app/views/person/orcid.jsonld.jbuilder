
if @account.size == 1
  json.set! 'foaf:accountName', @account.first['account_name_tesi']
end
