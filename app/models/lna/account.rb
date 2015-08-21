module Lna
  class Account < ActiveFedora::Base

    # Hash with properties for a Dartmouth Account.
    DART_PROPERTIES = { title: 'Dartmouth',
                     online_account: 'www.dartmouth.edu',
                     account_service_homepage: 'dartdm.dartmouth.edu' }
    
    # An Account can belong to a Person or an Organization
    belongs_to :account_holder, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::FOAF.account
  
    validates_presence_of :account_holder, :title, :online_account,
                          :account_name, :account_service_homepage

    validate :account_holder_type
  
    property :title, predicate: ::RDF::DC.title, multiple: false do |index|
      index.as :stored_searchable
    end
  
    property :online_account, predicate: ::RDF::FOAF.OnlineAccount, multiple: false do |index|
      index.as :stored_searchable # Should not be added to the search query!
    end
 
    property :account_name, predicate: ::RDF::FOAF.accountName, multiple: false do |index|
      index.as :stored_searchable # Should not be added to the search query!
    end

    property :account_service_homepage, predicate: ::RDF::FOAF.accountServiceHomepage, multiple: false do |index|
      index.as :stored_searchable # Should not be added to the search query!
    end

    # Validation to assure account_holder is a Lna::Person or
    # Lna::Organization.
    def account_holder_type
      unless(account_holder.is_a?(Lna::Person) ||
             account_holder.is_a?(Lna::Organization))
        errors.add(:account_holder, 'must be a Lna::Person or Lna::Organization')
      end
    end
  end
end
