module Lna
  class Organization < ActiveFedora::Base
    include Lna::OrganizationCoreBehavior

    has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
             as: :account_holder, inverse_of: :account_holder
    has_many :sub_organizations, class_name: 'Lna::Organization',
             as: :super_organizations, inverse_of: :super_organizations

    has_and_belongs_to_many :super_organizations, class_name: 'Lna::Organization',
                            predicate: ::RDF::Vocab::ORG.subOrganizationOf

    # Serializes organization, as per our needs, only supers of supers and subs of subs are
    # serialized. By not placing this limitation this method would infinitly recurse.
    #
    # @param [Hash] options Optional options that can be provided to the method.
    # @option options [Symbol] :only specified whether super or sub should be serialized
    # @return [Hash] serialization in hash form
    def serialize(options = {})
      hash =
        {
          label:      self.label,
          code:       self.code,
          alt_label:  self.alt_label,
          purpose:    self.purpose,
          hinman_box: self.hinman_box,
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

    # Retuns json serialization of object. Serialization is based of the serialize method.
    #
    # @return [String] json string of serialization
    def json_serialization
      JSON.generate(self.serialize)
    end

    def to_solr(solr_doc={})
      super.tap do |solr_doc|
        self.sub_organizations.reload
        unless self.sub_organizations.size.zero?
          solr_doc['hasSubOrganization_ssim'] = self.sub_organizations.map(&:id)
        end

        solr_doc['label_ssi'] = self.label
      end
    end
    
    # Converts given active organization to a historic organization and deletes
    # active organization.
    def self.convert_to_historic(active, end_date = Date.today, changed_by = nil)
      raise 'Cannot convert because organization still has accounts' if active.accounts.count > 0
      
      attrs = active.attributes.slice('memberships', 'people', 'resulted_from', 'code',
                                      'alt_label', 'label', 'begin_date', 'purpose', 'hinman_box')
      puts attrs
      historic = Lna::Organization::Historic.create!(attrs) do |h|
        h.historic_placement = active.json_serialization
        h.end_date = end_date
        h.changed_by = changed_by
      end

      active.destroy
      historic
    end
  end
end
