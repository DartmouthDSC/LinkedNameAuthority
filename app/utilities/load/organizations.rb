module Load
  class Organizations < Loader
    HR_ORG_LOADER = 'Organizations from HR Org view'

    # Keys for warnings hash.
    NEW_ORG                 = 'new organization'
    NEW_HISTORIC_ORG        = 'new historic organization'
    PREF_LABEL_UPDATED      = 'pref label updated'
    SUPER_ORG_UPDATED       = 'super org updated'
    RECORD_UPDATED          = 'record updated'
    NO_CHANGES_NECESSARY    = 'no changes were necessary' # Tried to update, but saw no changes.
    CHANGES_TO_HISTORIC_ORG = 'changes to historic org (lna record was not changed)'
    
    # Loading organizations from hr table.
    #
    # First, loading all the organization changed since the last time the load was done without an
    # end date. Then, loading all the organization that have an end_date ordered by end_date
    # (from earliest -> latest) and lowest in hierarchy to highest. In the second load :end_date
    # is not removed, and its not filtered by date last modified.
    def self.from_hr
      batch_load(HR_ORG_LOADER) do |loader|
        i = Import.last_successful_import(loader.title)
        last_import = (i) ? i.time_started : nil

        # Loading organization in order from highest to lowest in the hierarchy, without
        # an end date.
        Oracle::Organization::ORDERED_ORG_TYPES.reverse.each do |type|
          Oracle::Organization.find_by_type(type, last_import).each do |org|
            loader.into_lna(org.to_hash.except(:end_date))
          end
        end

        # Loading organizations that have an end date set and the end date not after today.
        Oracle::Organization::ORDERED_ORG_TYPES.each do |type|
          Oracle::Organization.find_ended_orgs_by_type(type).each do |org|
            loader.into_lna(org.to_hash.except(:super_organization))
          end
        end
      end
    rescue => e
      log_error(e, "Error loading #{HR_ORG_LOADER} in Oracle")
    end

    # Creates or updates the organization described by the hash. This method will catch any
    # errors.
    #
    # @param (see #into_lna!)
    # @return [Lna::Organization|Lna::Organization::Historic] if an organization is found,
    #   created or updated.
    # @return [nil] if theres a problem creating or updating the organization.
    def into_lna(hash)
      if hash[:hr_id]
        into_lna_by_hr_id!(hash)
      else
        raise NotImplementedError, 'Can only load org if hr_id is present.'
      end
    rescue => e
      log_error(e, hash.to_s)
      return nil
    end
    
    # Creates or updates Lna objects for the organization described by the given hash. Hr id and
    # label are required keys.
    #
    # Tries to find an organization that matches the hash. If an organization can be found
    # a new organization is not created. If an organization cannot be found:
    #   1. The :end_date key is removed from the hash and the organization is looked for again. If
    #      removing the :end_date key does return a result, then an end date was set and the
    #      organization should be converted to a historic organization only if the end_date is on
    #      or before Date.today.
    #   2. The organization is looked up by :hr_id. If looking up by :hr_id returns a result than
    #      some of the information in the hash was changed/updated.
    #         - If org is already historic, there shouldn't have been any changes in db, log
    #           a warning with changes, but don't make any of the changes on the object itself.
    #         - If :label was changed, add the old label to alt_label, and update the :label
    #         - If there are new alt_labels add them to alt_labels
    #         - If these's a new super organization, the old one is replaced.
    #         - For all other changes, they can just be updated.
    #         - If the hash contains an end_date (before or on Date.today) and after making all
    #           other changes, convert the organization to historic.
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
    # @param hash [Hash] hash containing organization info, hr_id and label key required
    # @return [Lna::Organization|Lna::Organization::Historic] organization that was found,
    #   created or updated
    # @return [Exception] if there are any problems creating or updating the organizations
    def into_lna_by_hr_id!(hash)
      # Argument Checking
      if !hash[:hr_id]
        raise ArgumentError, 'Must have a hr_id to create or update an org.'
      elsif !hash[:label]
        raise ArgumentError, 'Must have a label to create or update an org.'
      elsif hash[:end_date] && hash[:super_organization]
        raise ArgumentError, 'Historic organization cannot be created with a super organization.'
      end
      
      hash = hash.clone
      
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

      # Try to find the organization by searching by :hr_id. If found update record
      # as described above.
      if org = find_organization(hash.slice(:hr_id))        
        # Calculate difference between hash and org returned.
        diff = diff(org, hash)
        
        if diff.empty?
          log_warning(NO_CHANGES_NECESSARY, "#{org.label} (#{org.hr_id})")
        elsif org.historic? # Don't update object, log potential changes.
          diff = diff.map { |k, v| "#{k}: #{org.send(k)} -> #{v}" }.join(', ')
          log_warning(CHANGES_TO_HISTORIC_ORG, "#{org.label} (#{org.hr_id}): #{diff}")
        else
          if diff[:label]
            log_warning(PREF_LABEL_UPDATED, "#{org.label} -> #{diff[:label]}")
            org.alt_label += [org.label]
            org.label = diff[:label]
          end
          
          if diff[:alt_label] && !diff[:alt_label].empty?
            alt = diff[:alt_label].reject { |i| org.alt_label.include? i }
            org.alt_label += alt
          end
          
          if super_org
            if super_org.historic?
              raise ArgumentError, "Historic org #{super_org.label} cannot be a super organization"
            end
            
            if org.super_organizations.size <= 1
              org.super_organizations = [super_org]
              log_warning(SUPER_ORG_UPDATED, "#{org.label} (#{org.hr_id})")
            else
              raise 'org has more than one super and could not determine which one to delete'
            end
          end
          
          org.save!
          
          org.update(diff.except(:label, :alt_label, :super_organization_id, :end_date))
          log_warning(RECORD_UPDATED, "#{org.label} (#{org.hr_id})")
          
          # If end_date is set, convert the organization to historic.
          if diff[:end_date]
            org = Lna::Organization.convert_to_historic(org, diff[:end_date])
            log_warning(NEW_HISTORIC_ORG, org.label)
          end
        end
        return org
      end

      # Create a new organization.
      # If end date is set a historic organization needs to be created, otherwise an
      # active organization should be created.
      hash.delete(:super_organization_id)
      hash.compact! # Remove any nil valued keys.
      if hash[:end_date]
        org = Lna::Organization::Historic.create!(hash)
      else
        org = Lna::Organization.create!(hash)
        # If super organization was found, set it. 
        if super_org
          if super_org.historic?
            raise ArgumentError, "Historic org #{super_org.label} cannot be a super organization"
          end
          
          org.super_organizations << super_org
          org.save!
        end
      end

      value = hash[:hr_code] ? "#{hash[:label]}(#{hash[:hr_id]})" : hash[:label]
      log_warning(NEW_ORG, value)
      org
    end


    # Return hash with differences between org given and hash.
    def diff(org, hash)
      hash.compact.reject do |k, v|
        if k == :alt_label
          v.all? { |i| org.alt_label.include? i }
        # Ignore end date if after today
        elsif k == :end_date && (Date.parse(hash[:end_date]) > Date.today)
          true
        elsif k == :end_date && org.active?
          false
        elsif k == :super_organization_id
          (org.active?) ? org.super_organization_ids.include?(v) : true
        else
          v = Date.parse(v) if k == :end_date || k == :begin_date
          org.send(k) == v 
        end
      end
    end
  end
end
