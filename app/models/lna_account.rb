class LnaAccount < ActiveFedora::Base

  belongs_to :LnaPerson
  
  property :title, predicate: ::RDF::DC.title, multiple: false
  property :online_account, predicate: ::RDF::FOAF.onlineAccount, multiple: false
  property :account_name, predicate: ::RDF::FOAF.accountName, multiple: false
  property :account_service_homepage, ::RDF::FOAF.accountServiceHomepage, multiple: false

end
