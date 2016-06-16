module Load
  class People < Loader
    HR_EMPLOYEE = 'People from HR'
    
    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    NEW_PERSON = 'new person'
    NEW_MEM = 'new membership'
    NEW_ACCOUNT = 'new account'
    CHANGE_PRIMARY_ORG = 'changes primary org'
    UPDATING_MEMBERSHIP = 'updating membership'

    # Load appointments/memberships from view into a Human Resources table. Memberships that have
    # vanished from the view are ended.
    def self.from_hr
      batch_load(HR_EMPLOYEE) do |loader|
        begin
          # Loads memberships with a "valid" title (not Temporary or Non-Paid) that have been
          # modified since the last load. Primary memberships are loaded first.

          last_import = Import.last_successful_import(HR_EMPLOYEE)
          
          Oracle::Employee.with_title(modified_since: last_import).primary.find_each do |p|
            loader.into_lna(p.to_hash)
          end

          Oracle::Employee.with_title(modified_since: last_import).not_primary.find_each do |p|
            loader.into_lna(p.to_hash)
          end

          # Add an end date of Date.today to memberships that have disapeared from the table.
          
          # Search for memberships that were loaded from HRMS and don't have an end date.
          q = ActiveFedora::SolrQueryBuilder.construct_query(
            [
              ['source_tesi', 'HRMS'],
              ['has_model_ssim', 'Lna::Membership'],
              ['end_date_dtsi', nil]
            ]
          )
          docs = ActiveFedora::SolrService.query(q, rows: 10000)

          terminated = []

          # Iterate through each membership and check to see if its still in the Oracle table.
          # Matching based on netid, title and org id.
          docs.each do |doc|
            mem = Lna::Membership.load_instance_from_solr(doc['id'], doc)
            
            netid = mem.person.accounts.where(title: Lna::Account::DART_PROPERTIES[:title])
                    .first.account_name
            matching = Oracle::Employee.where(netid: netid, title: mem.title,
                                              department_id: mem.organization.hr_id)

            if matching.count.zero?
              terminated << "#{mem.person.full_name}, #{mem.title}, #{mem.id}"
              loader.into_lna(
                {
                  netid: netid,
                  membership: {
                    title: mem.title,
                    end_date: Date.today,
                    org: { hr_id: mem.organization.hr_id }
                  }
                }
              )
            end
          end

          puts terminated.join("\n")           
        rescue => e
          loader.log_error(e, "Error loading #{HR_EMPLOYEE} in Oracle")
        end
      end
    end

    def self.from_netid(netid)
      batch_load(HR_EMPLOYEE) do |loader|
        Oracle::Employee.where(netid: netid).order(:primary_flag).each do |person|
          loader.into_lna(person.to_hash)
        end
      end
    end
    
    
    # Creates or updates Lna objects for the person described by the given hash.
    #
    # @example Example of hash
    #   lna_hash = { netid: 'd00000k',
    #                person: {
    #                          full_name:   'Carla Galarza',
    #                          given_name:  'Carla',
    #                          family_name: 'Galarza',
    #                          mbox:        'Carla.Galarza@dartmouth.edu',
    #                          homepage:    ['www.dartmouth.edu/d00000k']
    #                        },
    #                membership: {
    #                              primary: true
    #                              title: 'Programmer/Analyst',
    #                              begin_date: '2001-01-01',
    #                              org: {
    #                                     label: 'Library',
    #                                     alt_label: ['DLC']
    #                                     hr_id:  '0021'
    #                                    }
    #                            },
    #               }
    #
    # @param hash [Hash] hash containing person, account and membership info
    # @return [Lna::Person] person that was created or updated
    # @return [nil] if there was a problem creating of updating the person
    def into_lna(hash)
      if hash[:netid]
        into_lna_by_netid!(hash[:netid], hash.except(:netid))
      else
        raise NotImplementedError, 'Can only import if netid is present.'
      end
    rescue NotImplementedError, ArgumentError => e
      log_error(e, hash.to_s)
      return nil
    rescue => e
      value = (hash[:person] && hash[:person][:full_name]) ?
                "#{hash[:person][:full_name]}(#{hash[:netid]})" :
                hash[:netid]
      log_error(e, value)
      return nil
    end
    
    # Creates or updates Lna objects for the person that has the given netid. Can create account,
    # membership and person objects. Importing people will not create organizations; any
    # organizations used should already by present.
    #
    # @param netid [String] Dartmouth identifier
    # @param hash [Hash] hash containing person, account and membership info
    # @return [Lna::Person] person that was created or updated
    # @return [Exception] if there a problem creating or updating person
    def into_lna_by_netid!(netid, hash)
      # Argument checking.
      if netid.nil?
        raise ArgumentError, "Netid cannot be nil"
      elsif !hash[:person] && !hash[:membership]
        raise ArgumentError, 'Must have a :person or :membership key in hash.'
      elsif hash[:membership] && !hash[:membership][:org]
        raise ArgumentError, 'Membership must have an organization.'
      end
      
      if person = find_person_by_netid(netid)
        # Update person record.
        person.update(hash[:person]) if hash[:person]
        
        # Update primary organization, if necessary.
        if hash[:membership][:primary]
          org = find_organization!(hash[:membership][:org])
          unless org.id == person.primary_org.id
            person.primary_org = org
            log_warning(CHANGE_PRIMARY_ORG, "#{person.full_name} (#{netid})")
          end
          person.save
        end
        
        # Create or update memberships.
        mem_hash = clean_mem_hash(hash[:membership])
        
        if mem = person.matching_membership(hash[:membership]) # matching on title and hr_id.
          mem.update(mem_hash)
          log_warning(UPDATING_MEMBERSHIP, "'#{mem.title}' for #{person.full_name} (#{netid})")
        else
          mem = Lna::Membership.create!(mem_hash) do |m|
            m.person = person
            m.organization = find_organization!(hash[:membership][:org])
          end
          person.save!
          log_warning(NEW_MEM, "'#{mem.title}' for #{person.full_name} (#{netid})")
        end
      else   # Create new person.
        # Checking arguments.
        if !hash[:membership] || !hash[:membership][:primary]
          raise ArgumentError, 'Primary membership required to create new person.'
        elsif !hash[:person]
          raise ArgumentError, 'Person hash required to create new person.'
        end
        
        # Find primary org.
        org = find_organization!(hash[:membership][:org])
        
        # Make person and set primary org.
        person = Lna::Person.create!(hash[:person]) do |p|
          p.primary_org = org
        end
        
        log_warning(NEW_PERSON, "#{person.full_name} (#{netid})")
        
        # Make account and set as account for person.
        accnt = Lna::Account.create!(dart_account_hash(netid)) do |a|
          a.account_holder = person
        end
        log_warning(NEW_ACCOUNT, "#{accnt.title} account for #{person.full_name} (#{netid})")
      
        # Make membership, belonging to org and person.
        mem_hash = clean_mem_hash(hash[:membership])
        mem = Lna::Membership.create!(mem_hash) do |m|
          m.person = person
          m.organization = org
        end
        log_warning(NEW_MEM, "'#{mem.title}' for #{person.full_name} (#{netid})")

        person.save!
      end
      person
    end

    private
    
    # Removes :primary and :org keys from membership hash.
    def clean_mem_hash(hash)
      hash.except(:org, :primary)
    end
  end
end
