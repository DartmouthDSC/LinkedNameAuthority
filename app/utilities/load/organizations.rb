module Load
  class Organizations < Loader
    HR_ORG_LOADER = 'Organizations from HR Org view'

    # Keys for warnings hash.
    NEW_ORG            = 'new organization'
    NEW_HISTORIC_ORG   = 'new historic organization'
    PREF_LABEL_UPDATED = 'pref label updated'
    SUPER_ORG_UPDATED  = 'super org updated'
    RECORD_UPDATED     = 'record updated'
    
    # Loading organizations from hr table.
    #
    # First, loading all the organization changed since the last time the load was done without an
    # end date. Then, loading all the organization that have an end_date ordered by end_date
    # (from earliest -> latest) and lowest in hierarchy to highest. In the second load :end_date
    # is not removed.
    def self.from_hr
      batch_load(HR_ORG_LOADER) do |loader|
        # Loading organization in order from highest to lowest in the hierarchy, without
        # an end date.
        Oracle::Organization::ORDERED_ORG_TYPES.reverse.each do |type|
          Oracle::Organization.find_by_type(type).each do |org| # date last modified.
            hash = org.to_hash.except(:end_date)
            loader.into_lna(hash)
          end
        end

        # Loading organizations that have an end date set.
        Oracle::Organization::ORDERED_ORG_TYPES.each do |type|
          Oracle::Organization.find_ended_orgs_by_type(type).each do |org|
            hash = org.to_hash.except(:super_organization)
            loader.into_lna(hash)
          end
        end        
      end
    end

    # Creates or updates the organization described by the hash. This method will catch any
    # errors. Errors are raised if throw_errors is true, otherwise it returns nil.
    #
    # @param (see #into_lna!)
    # @return [Lna::Organization|Lna::Organization::Historic] if an organization is found,
    #   created or updated.
    # @return [nil] if theres a problem creating or updating the organization.
    def into_lna(hash)
      into_lna!(hash)
    rescue => e
      log_error(e, hash.to_s)
      raise e if throw_errors
      return nil
    end

    private
    
    # Creates or updates Lna objects for the organization described by the given hash.
    #
    # Tries to find an organization that matches the hash. If an organization can be found
    # a new organization is not created. If an organization cannot be found:
    #   1. The :end_date key is removed from the hash and the organization is looked for again. If
    #      removing the :end_date key does return a result, then an end date was set and the
    #      organization should be converted to a historic organization only if the end_date is on
    #      or before Date.today.
    #   2. The organization is looked up by :hr_id. If looking up by :hr_id returns a result than
    #      some of the information in the hash was changed/updated.
    #         - If :label was changed, add the old label to alt_label, and update the :label
    #         - If there are new alt_labels add them to alt_labels
    #         - If these's a new super organization, the old one is replaced.
    #         - For all other changes, they can just be updated.
    #         - If the hash contains an end_date and the org returned is active, after making all
    #           other changes, convert the organization to historic
    #   3. If after these other searches an organization is not found, then a new organization is
    #      created.
    #
    #
    # @note This code assumes that each organization only has one super organization. If it
    #   becomes apparent that we need to add the ability to load multiple super organizations
    #   for each organization. Then the code that updates super organizations will have to
    #   be revisted.
    #
    # @example Example of hash
    #   lna_hash = { 
    #                label: 'Library',
    #                alt_label: ['DLC'],
    #                hr_id: '1234',
    #                kind: 'SUBDIV',
    #                hinman_box: '0000'
    #                start_date: '01-01-2001',
    #                end_date: nil,
    #                super_organization: { label: 'Provost' }
    #              }
    #
    # @private
    #
    # @param hash [Hash] hash containing organization info
    # @return [Lna::Organization|Lna::Organization::Historic] organization that was found,
    #   created or updated
    # @return [Exception] if there are any problems creating or updating the organizations
    def into_lna!(hash)
      raise ArgumentError, 'Must have a label to find or create an organization.' unless hash[:label]
      if hash[:end_date] && hash[:super_organization]
        raise ArgumentError, 'Historic organization cannot be created with a super organization.'
      end

      # Find super organization.
      super_org = nil
      if super_hash = hash.delete(:super_organization)
        super_org = find_organization!(super_hash)
        hash[:super_organization_id] = super_org.id
      end

      # Return if organization found.
      if org = find_organization(hash)
        return org
      end

      # Try to find the organization again, this time searching without :end_date.
      if org = find_organization(hash.except(:end_date))
        # Convert organization from active to historic because an end date was set since the last
        # time it was loaded.
        if Date.parse(hash[:end_date]) <= Date.today
          org = Lna::Organization.convert_to_historic(org, hash[:end_date])
          log_warning(NEW_HISTORIC_ORG, hash[:label])
        end
        return org
      end

      # Try to find the organization again, this time searching by :hr_id. If found update record
      # as described above.
      if hash[:hr_id]
        if org = find_organization({ hr_id: hash[:hr_id] })
          if org.label != hash[:label]
            log_warning(PREF_LABEL_UPDATED, "#{org.label} => #{hash[:label]}")
            org.alt_label << org.label
            org.label = hash[:label]
          end

          hash[:alt_label].each do |i|
            unless hash.alt_label.includes? i
              hash.alt_label << i
            end
          end

          if super_org && (org.super_organizations.size >= 1)
            org.super_organizations = [super_org]
            log_warning(SUPER_ORG_UPDATED, "#{org.label}(#{org.hr_id})")
          else
            raise 'org has more than one super and could not determine which one to delete'
          end

          org.update(hash.except(:label, :alt_label, :super_organization_id, :end_date))
          log_warning(RECORD_UPDATED, "#{org.label}(#{org.hr_id})")

          org.save!
          
          # If end_date is set and an active organization is returned, convert the organization
          if hash[:end_date] && (Date.parse(hash[:end_date]) <= Date.today) && org.active?
            org = Lna::Organization.convert_to_historic(org, hash[:end_date])
            log_warning(NEW_HISTORIC_ORG, hash[:label])
          end

          puts "Update in Org #{org[:label]}"
          return org
        end
      end

      # Create a new organization.
      # If end date is set a historic organization needs to be created, otherwise an
      # active organization should be created.
      hash.delete(:super_organization_id)
      if hash[:end_date]
        org = Lna::Organization::Historic.create!(hash)
      else
        org = Lna::Organization.create!(hash)
        # If super organization was found, set it. 
        if super_org
          org.super_organizations << super_org
          org.save!
        end
      end

      value = hash[:hr_code] ? "#{hash[:label]}(#{hash[:hr_id]})" : hash[:label]
      log_warning(NEW_ORG, value)
      org
    end
  end
end
