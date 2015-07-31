class Lna::Organization < ActiveFedora::Base

  has_many :people, class_name: 'Lna::Person', as: :primary_org
  has_many :memberships, class_name: 'Lna::Membership', dependent: :destroy
           #predicate: ::RDF::Vocab::ORG.organization
  has_many :accounts, class_name: 'Lna::Account', as: :account_holder,
           inverse_of: :account_holder, dependent: :destroy
  
  has_many :sub_organizations, class_name: 'Lna::Organization',
           predicate: ::RDF::Vocab::ORG.hasSubOrganization,
           inverse_of: :super_organization
  
  belongs_to :super_organization, class_name: 'Lna::Organization',
             predicate: ::RDF::Vocab::ORG.subOrganizationOf

  belongs_to :resulted_from, class_name: 'Lna::Organization::ChangeEvent',
             predicate: ::RDF::Vocab::ORG.resultedFrom
  belongs_to :changed_by, class_name: 'Lna::Organization::ChangeEvent',
             predicate: ::RDF::Vocab::ORG.changedBy
  
  validates_presence_of :label

  type ::RDF::Vocab::ORG.Organization
  
  property :label, predicate: ::RDF::SKOS.prefLabel, multiple: false
  property :alt_label, predicate: ::RDF::SKOS.altLabel
  
end
