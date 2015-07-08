class Lna::Organization < ActiveFedora::Base

  has_many :people, class_name: 'Lna::Person',
            predicate: ::RDF::Vocab::ORG.hasMember
  has_many :memberships, class_name: 'Lna::Membership',
           predicate: ::RDF::Vocab::ORG.organization
  has_many :sub_organizations, class_name: 'Lna::Organization',
           predicate: ::RDF::Vocab::ORG.hasSubOrganization
  
  belongs_to :super_organization, class_name: 'Lna::Organization',
             predicate: ::RDF::Vocab::ORG.subOrganizationOf
  belongs_to :change_event, class_name: 'Lna::Organization::ChangeEvent',
             predicate: ::RDF::Vocab::ORG.resultedFrom
  
  validates_presence_of :pref_label
  
  property :pref_label, predicate: ::RDF::SKOS.prefLabel, multiple: false
  property :alt_label, predicate: ::RDF::SKOS.altLabel
  
end
