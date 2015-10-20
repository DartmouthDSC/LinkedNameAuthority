module Lna
  class Organization < ActiveFedora::Base
    include Lna::OrganizationCoreBehavior

    has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
             as: :account_holder, inverse_of: :account_holder
    has_many :sub_organizations, class_name: 'Lna::Organization',
             as: :super_organizations, inverse_of: :super_organizations

    has_and_belongs_to_many :super_organizations, class_name: 'Lna::Organization',
                            predicate: ::RDF::Vocab::ORG.subOrganizationOf

  end
end
