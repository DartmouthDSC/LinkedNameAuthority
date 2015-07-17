class Lna::Account < ActiveFedora::Base

  # An Account can belong to a Person or an Organization
  belongs_to :account_holder, class_name: 'ActiveFedora::Base', predicate: ::RDF::FOAF.account
  
  validates_presence_of :account_holder, :title, :online_account, :account_name,
                        :account_service_homepage
  
  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :online_account, predicate: ::RDF::FOAF.OnlineAccount, multiple: false do |index|
    index.as :displayable
  end
 
  property :account_name, predicate: ::RDF::FOAF.accountName, multiple: false do |index|
    index.as :displayable
  end

  property :account_service_homepage, predicate: ::RDF::FOAF.accountServiceHomepage, multiple: false do |index|
    index.as :displayable
  end
end
