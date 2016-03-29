module Load
  class Organizations < Loader
    HR_ORG_LOADER = 'Organizations from HR Org view'

    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    NEW_HISTORIC_ORG = 'new historic organization'
    CHANGE_EVENT_TRIGGERED = 'change event triggered'
    
    # Loading organizations from hr table.
    #
    # First, loading all the organization changed since the last time the load was done without an
    # end date. Then, loading all the organization that have an end_date ordered by end_date
    # (from earliest -> latest) and lowest in hierarchy to highest. In the second load :end_date
    # is not removed.
    # 
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

    # Creates or updates Lna objects for the organization described by the Hash. This method
    # will catch any errors. Errors are raised if throw_errors is true, otherwise it returns
    # nil.
    #
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
    
    # Creates or updates Lna objects for the organization described by the given hash.
    #
    # Tries to find an organization that matches the hash exactly. If an organization can be found
    # a new organization is not created. If an organization cannot be found:
    #   1. The :end_date key is removed from the hash and the organization is looked for again. If
    #      removing the :end_date key does return a result, then an end date was set and the
    #      organization should be converted to a historic organization only if the end_date is on
    #      or before Date.today.
    #   2. The organization is looked up by :hr_id. If looking up by :hr_id returns a result than
    #      some of the information in the hash was changed/updated, therefore a change event
    #      should be triggered. If an active organization is returned and the hash contains an
    #      :end_date, then the organization is updated with all the information in the hash
    #      except for the :end_date. The new active organization created is then converted to a
    #      historic organization, using the :end_date given.
    #   3. If after these other searches an organization is not found, then a new organization is
    #      created.
    #
    # @example Example of hash
    #   lna_hash = { 
    #                label: 'Library',
    #                alt_label: ['DLC'],
    #                hr_id: '1234',
    #                kind: 'SUBDIV',
    #                start_date: '01-01-2001',
    #                super_organization: { label: 'Provost' }
    #              }
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

      super_hash = hash.delete(:super_organization)

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
          log_warning(NEW_HISTORIC_ORG, "#{hash[:label]}")
        end
        return org
      end

      # Try to find the organization again, this time searching by :hr_id.
      if hash[:hr_id]
        if org = find_organization({ hr_id: hash[:hr_id] })
          # Trigger change event and return new org.
          puts "Trigger Change Event"
          log_warning(CHANGE_EVENT_TRIGGERED, "#{hash[:label]}(#{hash[:hr_id]})")
          return org
        end
      end

      # Create a new organization.
      # If end date is set a historic organization needs to be created, otherwise an
      # active organization should be created.
      if hash[:end_date]
        org = Lna::Organization::Historic.create!(hash)
      else
        # Find super organization, if one is given.
        if super_hash && !super_hash.empty?
          unless super_org = find_organization(super_hash)
            raise ArgumentError, "Could not find super organization with fields #{super_hash.to_s}"
          end
        end

        org = Lna::Organization.create!(hash) do |o|
          o.super_organizations << super_org if super_org
        end
      end

      value = hash[:hr_code] ? "#{hash[:label]}(#{hash[:hr_id]})" : hash[:label]
      log_warning(NEW_ORG, value)
    end
  end
end
