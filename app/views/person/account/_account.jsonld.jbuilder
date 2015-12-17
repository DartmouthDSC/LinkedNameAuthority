
if id
  json.set! '@id', id
else
  json.set! '@id', '#' + FedoraID.shorten(account['account_ssim'].first)
end
json.set! '@type', 'foaf:OnlineAccount'
json.set! 'dc:title', account['title_tesi']
json.set! 'foaf:accountName', account['account_name_tesi']
json.set! 'foaf:accountServiceHomepage', account['account_service_homepage_tesi']
