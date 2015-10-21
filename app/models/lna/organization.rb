module Lna
  class Organization < ActiveFedora::Base
    include Lna::OrganizationCoreBehavior

    has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
             as: :account_holder, inverse_of: :account_holder
    has_many :sub_organizations, class_name: 'Lna::Organization',
             as: :super_organizations, inverse_of: :super_organizations

    has_and_belongs_to_many :super_organizations, class_name: 'Lna::Organization',
                            predicate: ::RDF::Vocab::ORG.subOrganizationOf

    
    def serialize(options = {})
      hash =
        {
          label:      self.label,
          code:       self.code,
          alt_label:  self.alt_label,
          begin_date: self.begin_date.to_s
        }

      only = options[:only]      
      if !only || only == :sub
        sub_orgs = self.sub_organizations.to_a.map { |s| s.serialize(only: :sub) }
        hash[:sub_organizations] = sub_orgs unless sub_orgs.empty?
      end

      if !only || only == :super
        super_orgs = self.super_organizations.to_a.map { |s| s.serialize(only: :super) }
        hash[:super_organizations] = super_orgs unless super_orgs.empty?
      end
      
      hash
    end

    def json_serialization
      JSON.generate(self.serialize)
    end
  end
end
