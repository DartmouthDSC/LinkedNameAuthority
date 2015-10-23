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

    # Converts given active organization to a historic organization and deletes
    # active organization.
    def self.convert_to_historic(active, end_date = Date.today, changed_by = nil)

      raise 'Cannot convert because organization still has accounts' if active.accounts.count > 0
      
      serialization = active.json_serialization
      
      historic = Lna::Organization::Historic.create! do |h|
        h.memberships = active.memberships
        h.people = active.people
        h.resulted_from = active.resulted_from
        h.identifier = active.identifier
        h.alt_label = active.alt_label
        h.label = active.label
        h.begin_date = active.begin_date
        h.end_date = end_date
        h.historic_placement = serialization
        h.changed_by = changed_by

      end

      active.destroy
      historic
    end
    
  end
end
