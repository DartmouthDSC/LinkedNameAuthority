json.partial! 'persons/base'

#json.queryString params[:person].to_query

json.partial! 'persons/graph'

