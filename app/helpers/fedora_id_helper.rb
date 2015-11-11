module FedoraIdHelper
  def simplify_fedora_id(id)
    id[/(?<simple>[a-zA-Z0-9-]+$)/, "simple"]
  end  
end
