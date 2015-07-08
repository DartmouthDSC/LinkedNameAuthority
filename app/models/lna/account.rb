class Lna::Account < ActiveFedora::Base

  belongs_to :person, class_name: 'Lna::Person', predicate: ::RDF::FOAF.account
  
  validates_presence_of :person, :title, :online_account, :account_name,
                        :account_service_homepage
  
  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :online_account, predicate: ::RDF::FOAF.OnlineAccount, multiple: false do |index|
    index.as :displayable
  end
 
  property :account_name, predicate: ::RDF::FOAF.accountName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :account_service_homepage, predicate: ::RDF::FOAF.accountServiceHomepage, multiple: false do |index|
    index.as :stored_searchable
  end
end
