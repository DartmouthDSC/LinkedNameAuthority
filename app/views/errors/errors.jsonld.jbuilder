json.prettify!

json.status 'failure'
json.error @rescue_response.to_s

case @exception.class.to_s
when 'RSolr::Error::Http'
  json.message 'Query Invalid'
else
  json.message @exception.message
end
