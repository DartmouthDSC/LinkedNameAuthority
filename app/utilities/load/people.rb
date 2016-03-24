module Load
  class People < Loader
    HR_FACULTY_LOADER = 'People from HR faculty view'
    
    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    NEW_PERSON = 'new person'
    NEW_MEM = 'new membership'
    NEW_ACCOUNT = 'new account'
    CHANGE_PRIMARY_ORG = 'changes primary org'
    
    def self.from_hr_faculty_view
      batch_load(HR_FACULTY_LOADER) do |loader|
        Oracle::Faculty.find_each do |person|
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
    #                              org: {
    #                                     label: 'Library',
    #                                     alt_label: ['DLC']
    #                                     code:  'LIB'
    #                                    }
    #                            },
    #               }
    #
    # @param hash [Hash] hash containing person, account and membership info
    # @return [Lna::Person] person that was created or updated
    # @return [nil] if there was a problem creating of updating the person
    def into_lna(hash = {})
      begin
        if hash.key?(:netid) && hash[:netid]
          into_lna_by_netid!(hash[:netid], hash)
        else
          raise NotImplementedError, 'Can only import if netid is present.'
        end
      rescue NotImplementedError, ArgumentError => e
        log_error(e, hash.to_s)
        raise e if throw_errors
        return nil
      rescue => e
        value = (hash[:person] && hash[:person][:full_name]) ?
                  "#{hash[:person][:full_name]}(#{hash[:netid]})" :
                  hash[:netid]
        log_error(e, value)
        raise e if throw_errors
        return nil
      end  
    end
    
    private
    
    # Creates or updates Lna objects for the person that has the given netid. Importing people
    # will not create organizations. Any organizations used should already by present.
    #
    # @private
    #
    # @param netid [String] Dartmouth identifier
    # @param hash [Hash] hash containing person, account and membership info
    # @return [Lna::Person] person that was created or updated
    # @return [Exception] if there a problem creating or updating person
    def into_lna_by_netid!(netid, hash = {})
      # Argument checking.
      if !hash[:person] && !hash[:membership]
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
            log_warning(CHANGE_PRIMARY_ORG, "#{person.full_name}(#{netid})")
          end
          person.save
        end
        
        # Create or update memberships.
        mem_hash = clean_mem_hash(hash[:membership])
        
        if mem = person.matching_membership(hash[:membership])
          mem.update(mem_hash)
        else
          mem = Lna::Membership.create!(mem_hash) do |m|
            m.person = person
            m.organization = find_organization!(hash[:membership][:org])
            m.begin_date = Date.today
          end
          person.save!
          log_warning(NEW_MEM, "'#{mem.title}' for #{person.full_name}(#{netid})")
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
        
        log_warning(NEW_PERSON, "#{person.full_name}(#{netid})")
        
        # Make account and set as account for person.
        accnt = Lna::Account.create!(dart_account_hash(netid)) do |a|
          a.account_holder = person
        end
        log_warning(NEW_ACCOUNT, "#{accnt.title} account for #{person.full_name}(#{netid})")
      
        # Make membership, belonging to org and person.
        mem_hash = clean_mem_hash(hash[:membership])
        mem = Lna::Membership.create!(mem_hash) do |m|
          m.person = person
          m.organization = org
          m.begin_date = Date.today
        end
        log_warning(NEW_MEM, "'#{mem.title}' for #{person.full_name}(#{netid})")
        
        person.save
      end
      person
    end

    def dart_account_hash(netid)
      { account_name: netid }.merge(Lna::Account::DART_PROPERTIES)
    end
    
    # Find dartmouth account with the matching netid.
    #
    # @param netid [String] netid to lookup
    # @return [nil] if no matching account was found
    # @return [Lna::Account] if one matching account was found
    def find_dart_account(netid)
      hash = dart_account_hash(netid)
      accounts = Lna::Account.where(hash)

      case accounts.count
      when 0
        nil
      when 1
        accounts.first
      else
        raise ArgumentError, "More than one account has this netid."
      end
    end

    # Find person with the matching netid.
    #
    # @param netid [String] netid to lookup
    # @return [nil] if no matching person was found
    # @return [Lna::Person] if one matching person was found
    def find_person_by_netid(netid)
      if account = find_dart_account(netid)
        acnt_holder = account.account_holder
        raise "Netid is associated with a #{acnt_holder.class}." unless person.is_a?(Lna::Person)
        acnt_holder
      else
        nil
      end
    end    
    
    # Removes :primary and :org keys from membership hash.
    def clean_mem_hash(hash)
      hash.except(:org, :primary)
    end
  end
end
