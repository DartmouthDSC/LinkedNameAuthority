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
    # active organization.
    #
    # All fields except accounts, sub_organizations, and super_organizations are moved over to
    # the historic organization. Changed_by is set, if a change event is passed in. 
    #
    # @param [Lna::Organization] active
    # @param [Date] end_date
    # @param [Lna::Organization::ChangeEvent] changed_by
    def self.convert_to_historic(active, end_date = Date.today, changed_by = nil)
      raise 'Cannot convert because organization still has accounts' if active.accounts.count > 0
      
      attrs = active.attributes.slice('memberships', 'people', 'resulted_from', 'hr_id',
                                      'alt_label', 'label', 'begin_date', 'kind', 'hinman_box')

      historic = Lna::Organization::Historic.create!(attrs) do |h|
        h.historic_placement = active.json_serialization
        h.end_date = end_date
        h.changed_by = changed_by
      end

      # Remove all related objects and destroy active.
      active.sub_organizations = []
      active.super_organizations = []
      active.resulted_from = nil
      active.save!
      active.destroy
      
      historic
    end

    # Link two organizations through a change event.
    #
    # If the old organization has a changed by event or if the new organization has a result from
    # event, use that change event. Otherwise create a new one based using the description and
    # date given. Date and description are ignored if a change event is already present.
    #
    # If old is an active organization then:
    #   - all accounts are migreated to the new organization
    #   - all sub organizations and super organizations are copied over to the new organizations
    #   - memberships
    #       - that do not have an end date will be migrated to the new organization
    #       - that do have an end date will be move to the historic organization
    #   - people
    #       - that do not have any active memberships will move to the historic organization
    #       - that have an active membership related to old will be moved to the new organization
    #       - otherwise, person will be moved to the organization of the first active membership
    #   - change_by is set
    #
    # If old is a historic organization then:
    #   - change_by is set
    #
    # @param [Lna::Organization::Historic|Lna::Organization] old
    # @param [Lna::Organization] new
    # @param [String] description
    # @param [Date] date
    # @return [Lna::Organization::ChangeEvent]
    def self.trigger_change_event(old, new, description: nil, date: Date.today)
      if old.changed_by && new.resulted_from
        unless old.changed_by == new.resulted_from
          raise ArgumentError, 'old.changed_by and new.resulted_from events must be the same'
        end
      end
      
      change_event = if old.changed_by
                       old.changed_by
                     elsif new.resulted_from
                       new.resulted_from
                     else
                       Lna::Organization::ChangeEvent.new(
                         description: description,
                         at_time:     date
                       )
                     end

      # If old is an active organization it needs to be converted to a historic organization.
      if old.instance_of? Lna::Organization

        # Migrate people from old -> new, if there's an active membership still related to org. If
        # there are no active memberships, the person stays with the historic org. Otherwise it is
        # moved to one of the orgs for which it still has an active membership.
        old.people.each do |person|
          active_mems_orgs = person.memberships.select(&:active?).map(&:organization)
          
          next if active_mems_orgs.count.zero?

          person.primary_org = (active_mems_orgs.include? old) ?
                                 new : active_mems_orgs.first
          person.save!
        end
        new.reload!
        old.reload!
        
        # Migrate memberships that have not ended from old -> new.
        old.memberships.each do |mem|
          if mem.active?
            mem.organization = new
            mem.save!
          end
        end
        old.reload!
        new.reload!
        
        # Copy sub_organizations and super_organization from old -> new.
        new.super_organizations.concat(old.super_organizations)
        new.sub_organization.contact(old.sub_organizations)
        new.reload!
        
        # Migrate accounts from old -> new.
        new.accounts = old.accounts
        new.reload!
        old.reload!
        
        # Make old historic.
        old_historic = convert_to_historic(old, date, change_event)
      else
        old.changed_by = change_event
      end
      
      # Set change event in new.
      new.resulted_from = change_event
      new.save!
      change_event.save!
      
      change_event
    end
  end
end
