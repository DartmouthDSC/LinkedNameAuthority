module Load
  class Organizations < Loader
    HR_ORG_LOADER_TITLE = 'Organizations from HR Org view'

    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    NEW_HISTORIC_ORG = 'new historic organization'
    
    ##  ORG_TYPE  COUNT(ORG_TYPE)
    ##  -------------------------
    ##  TPP       2   [ IGNORE THESE; THEY'LL BE REMOVED FROM THE VIEW ]
    ##  SCH       4
    ##  DIV       5
    ##  ACAD DIV  7
    ##  SUBDIV    13
    ##  SUBUNIT   99
    ##  DEPT      217
    ##  UNIT      348

    # Loading organizations from hr table.
    #
    # First, loading all the organization changed since the last time the load was done without an
    # end date. Then, loading all the organization that have an end_date ordered by end_date
    # (from earliest -> latest) and lowest in hierarchy to highest. In the second load :end_date
    # is not removed.
    # 
    def self.from_hr
      batch_load(HR_ORG_LOADER_TITLE) do |loader|
        # Loading organization in order from highest to lowest in the hierarchy.
        Oracle::Organization::ORDERED_ORG_TYPES.reverse.each do |org_type|
          Oracle::Organization.find_by(org_type: org_type) do |org| # date last modified.
            hash = org.to_hash
            hash.delete(:end_date)
            loader.into_lna(hash)
          end
        end
      end
    end

    # Creates or updates Lna objects for the organization described by the given hash.
    #
    # Tries to find an organization that matches the hash exactly. If an organization can be found
    # a new organization is not created. If an organization cannot be found:
    #   1. The :end_date key is removed from the hash and the organization is looked for again. If
    #      removing the :end_date key does return a result, then an end date was set and the
    #      organization should be converted to a historic organization only if the end_date is on
    #      or before Date.today.
    #   2. The organization is looked up by :code. If looking up by :code returns a result than
    #      some of the information in the hash was changed/updated, therefore a change event
    #      should be triggered. If an active organization is returned and the hash contains an
    #      :end_date, then the organization is updated with all the information in the hash
    #      except for the :end_date. The new active organization created is then converted to a
    #      historic organization, using the :end_date given.
    #  3. If after these other searches an organization is not found, then a new organization is
    #     created.
    #
    # @example Example of hash
    #   lna_hash = { 
    #                label: 'Library',
    #                alt_label: ['DLC'],
    #                code:  'LIB',
    #                start_date: '01-01-2001',
    #                super_organization: { label: 'Provost' }
    #              }
    #
    # @param hash [Hash] hash containing organization info
    # @return [Lna::Organization] organization that was created or updated
    def into_lna(hash = {})
      raise ArgumentError, 'Must have a label to find or create an organization.' unless hash[:label]

      # If the organization could not be found, attempt to find it by searching differently. If
      # it still cannot be found create a new one.
      unless org = find_organization(hash)

        # Search without end date.
        hash.delete(:end_date)
        if org = find_organization(hash)
          # convert organization from active to historic
        end
        
        # Trigger a change event if the data has changed.
        if hash.key? :code
          if org = find_organization({ code: hash[:code] })
            return org
          end
        end

        # Trigger a change event if end_date was set and end_date is today or before today
        
        # Find super organization, if one is given.
        if hash.key(:super_organization)
          super_hash = hash.delete(:super_organization)
          unless super_org = find_organization(super_hash)
            raise ArgumentError, "Could not find super organization with fields #{super_hash.to_s}"
          end
        end

        # If end date is set a historic organization needs to be created, otherwise an
        # active organization should be created.
        if hash.key(:end_date) && hash[:end_date]
          org = Lna::Organization.create!(hash) do |o|
            o.super_organizations << super_org if super_org
          end
        else
          hash.delete(:end_date)
          org = Lna::Organization::Historic.create!(hash)
        end
        
        value = hash[:code] ? "#{hash[:label]}(#{hash[:code]})" : hash[:label]
        log_warning(NEW_ORG, value)
      end
      org
    end    
  end
end
