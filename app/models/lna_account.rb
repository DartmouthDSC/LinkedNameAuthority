class LnaAccount < ActiveFedora::Base

  belongs_to :lna_person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isDependentOf

  validates_presence_of :dc_title, :foaf_online_account, :foaf_account_name,
                        :foaf_account_service_homepage
  
  property :dc_title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :foaf_online_account, predicate: ::RDF::FOAF.OnlineAccount, multiple: false do |index|
    index.as :displayable
  end
 
  property :foaf_account_name, predicate: ::RDF::FOAF.accountName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :foaf_account_service_homepage, predicate: ::RDF::FOAF.accountServiceHomepage, multiple: false do |index|
    index.as :stored_searchable
  end
  
end
