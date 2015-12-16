# The purpose of this module is to translate Fedora ID from the "short" version to
# there "longer" version and visa versa.

module FedoraID
  def self.shorten(id) #shorten
    id[/(?<simple>[a-zA-Z0-9-]+$)/, "simple"]
  end

  def self.lengthen(id) #elongate
    if id
      /(?<first>^[a-zA-Z0-9]+)-/ =~ id
      (first) ? first.scan(/[a-zA-Z0-9]{2}/).join('/') + '/' + id : id
    end
  end
end
