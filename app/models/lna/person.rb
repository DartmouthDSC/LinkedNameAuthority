class Lna::Person < ActiveFedora::Base
  
  has_many :memberships, class_name: 'Lna::Membership', dependent: :destroy
#           inverse_of: :person, as: :person
  has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
           as: :account_holder, inverse_of: :account_holder
  has_many :collections, class_name: 'Lna::Collection', dependent: :destroy,
           predicate: ::RDF::FOAF.publications
  
  #Not Working.
  #has_many :organizations, through: :memberships,
  #         class_name: 'Lna::Organization'
  
  belongs_to :primary_org, class_name: 'Lna::Organization',
             predicate: ::RDF::Vocab::ORG.reportsTo
             
  validates_presence_of :primary_org, :full_name, :given_name, :family_name
  
  property :full_name, predicate: ::RDF::FOAF.name, multiple: false do |index|
    index.as :displayable
  end

  property :given_name, predicate: ::RDF::FOAF.givenName, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :family_name, predicate: ::RDF::FOAF.familyName, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :title, predicate: ::RDF::FOAF.title, multiple: false do |index|
    index.as :displayable
  end
  
  property :image, predicate: ::RDF::FOAF.img, multiple: false do |index|
    index.as :displayable
  end
  
  property :mbox, predicate: ::RDF::FOAF.mbox, multiple: false do |index|
    index.as :displayable
  end
  
  property :mbox_sha1sum, predicate: ::RDF::FOAF.mbox_sha1sum, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :homepage, predicate: ::RDF::FOAF.homepage do |index|
    index.as :stored_searchable
  end  
end
