module Lna
  class Organization < ActiveFedora::Base
    include Lna::OrganizationCoreBehavior

    has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
             as: :account_holder, inverse_of: :account_holder
    has_many :sub_organizations, class_name: 'Lna::Organization',
                            as: :super_organizations, inverse_of: :super_organizations

    has_and_belongs_to_many :super_organizations, class_name: 'Lna::Organization',
                            predicate: ::RDF::Vocab::ORG.subOrganizationOf,
                            after_add: :reindex_sub, after_remove: :reindex_sub
    
    # Because has many associations are not usually indexed into solr, reindex the super
    # organization when its added or removed. That way the solr document includes the relationship.
    def reindex_sub(r)
      r.update_index
    end  

    def active?
      true
    end

    def historic?
      false
    end
    
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
          hr_id:      self.hr_id,
          alt_label:  self.alt_label,
          kind:       self.kind,
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
    # active organization. Both the active organizations and historic organization will have the
    # same ID.
    #
    # All fields except accounts, sub_organizations, and super_organizations are moved over to
    # the historic organization.
    #
    # @param [Lna::Organization] active
    # @param [Date] end_date
    # @returns [Lna::Organization::Historic] historic organization
    def self.convert_to_historic(active, end_date = Date.today)
      active.reload
      if active.accounts.count > 0
        raise ArgumentError, 'Cannot convert because organization still has accounts'
      end
      
      attrs = active.attributes.slice('resulted_from_id', 'hr_id', 'alt_label', 'label',
                                      'begin_date', 'kind', 'hinman_box')
      serialization = active.json_serialization

      # Temp organization object to temporarily hold memberships and people.
      temp = Lna::Organization.create!(attrs) do |t|
        t.people = active.people
        t.memberships = active.memberships
      end
        
      # Remove all related objects and destroy active.
      id = active.id
      active.reload
      active.sub_organizations = []
      active.super_organizations = []
      active.save!
      active.destroy(eradicate: true)

      # Create historic.
      historic = Lna::Organization::Historic.create!(attrs) do |h|
        h.id = id
        h.people = temp.people
        h.memberships = temp.memberships
        h.historic_placement = serialization
        h.end_date = end_date
      end

      # Destroy temp object.
      temp.reload
      temp.destroy(eradicate: true)
      
      historic
    end
  end
end
