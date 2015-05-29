class LnaAccount < ActiveFedora::Base

  belongs_to :LnaPerson, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
  
  property :dc_title, predicate: ::RDF::DC.title, multiple: false
  property :foaf_online_account, predicate: ::RDF::FOAF.OnlineAccount, multiple: false
  property :foaf_account_name, predicate: ::RDF::FOAF.accountName, multiple: false
  property :foaf_account_service_homepage, predicate: ::RDF::FOAF.accountServiceHomepage, multiple: false

end
