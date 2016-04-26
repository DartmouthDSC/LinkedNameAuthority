
json.status 'failure'
json.error @rescue_response.to_s

json.message @exception.message
