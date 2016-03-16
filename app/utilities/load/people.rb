module Load
  class People < Loader
    HR_FACULTY_IMPORT_TITLE = 'People from HR faculty view'
    
    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    NEW_PERSON = 'new person'
    NEW_MEM = 'new membership'
    NEW_ACCOUNT = 'new account'
    CHANGE_PRIMARY_ORG = 'changes primary org'
    SENT_EMAIL = 'Sent email'
    
    def self.from_hr_faculty_view
      batch_load(title: HR_FACULTY_IMPORT_TITLE, verbose: true, throw_errors: false,
                   emails: ENV['IMPORTER_EMAIL_NOTICES']) do |loader|
        Oracle::Faculty.find_each do |person|
          loader.into_lna(person.to_hash)
        end
        loader.send_email
        puts "[#{Time.now}] Output from Faculty Load\n #{import.output.to_yaml}"
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
    def into_lna(hash = {})
      begin
        if hash.key?(:netid) && hash[:netid]
          into_lna_by_netid(hash[:netid], hash)
        else
          raise NotImplementedError, 'Can only import if netid is present.'
        end
      rescue NotImplementedError => e
        add_to_errors(e.message, hash.to_s)
        raise if throw_errors
      rescue ArgumentError => e
        add_to_errors(e.message, hash.to_s)
        raise if throw_errors
      rescue StandardError => e
        value = (hash[:person] && hash[:person][:full_name]) ?
                  "#{hash[:person][:full_name]}(#{hash[:netid]})" :
                  hash[:netid]
        add_to_errors(e.message, value)
        raise if throw_errors
      end  
    end
    
    def send_email
      raise(ArgumentError, 'No email provided.') unless emails
      
      ImporterMailer.output_email(title, emails, self.output).deliver_now
      t = Time.now
      add_to_warnings(SENT_EMAIL, "to #{emails.join(', ')} on #{t.strftime('%c')}")
    end
    
    # Combine errors and warnings hash into one. Warnings will only be combined if the verbose
    # flag is true.
    def output
      output = Hash.new
      output['error'] = errors unless errors.empty?
      output['warning'] = warnings if !warnings.empty? && verbose
      output
    end
    
    private
    
    # Creates or updates Lna objects for the person that has the given netid.
    #
    # @private
    #
    # @param netid [String] Dartmouth identifier
    # @param hash [Hash] hash containing  person, account and membership info
    # @return [Lna::Person] person that was created or updated
    def into_lna_by_netid(netid, hash = {})
      # Argument checking.
      if !hash[:person] && !hash[:membership]
        raise ArgumentError, 'Must have a :person or :membership key in hash.'
      elsif hash[:membership] && !hash[:membership][:org]
        raise ArgumentError, 'Membership must have an organization.'
      end
      
      account_hash = { account_name: netid }.merge(Lna::Account::DART_PROPERTIES)
      accounts = Lna::Account.where(account_hash)
      
      if accounts.count > 1
        raise "More than one account has this netid."
      elsif accounts.count == 1  # Update person.
        person = accounts.first.account_holder
        
        raise "Netid is associated with a #{person.class}." unless person.is_a?(Lna::Person)
        
        # Update person record.
        person.update(hash[:person]) if hash[:person]
        
        # Update primary organization, if necessary.
        if hash[:membership][:primary]
          org = find_or_create_org(hash[:membership][:org])
          unless org.id == person.primary_org.id
            person.primary_org = org
            add_to_warnings(CHANGE_PRIMARY_ORG, "#{person.full_name}(#{netid})")
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
            m.organization = find_or_create_org(hash[:membership][:org])
            m.begin_date = Date.today
          end
          person.save!
          add_to_warnings(NEW_MEM, "'#{mem.title}' for #{person.full_name}(#{netid})")
        end
      else   # Create new person.
        # Checking arguments.
        if !hash[:membership] || !hash[:membership][:primary]
          raise ArgumentError, 'Primary membership required to create new person.'
        elsif !hash[:person]
          raise ArgumentError, 'Person hash required to create new person.'
        end
        
        # Find or create primary org.
        org = find_or_create_org(hash[:membership][:org])
        
        # Make person and set primary org.
        person = Lna::Person.create!(hash[:person]) do |p|
          p.primary_org = org
        end
        
        add_to_warnings(NEW_PERSON, "#{person.full_name}(#{netid})")
        
        # Make account and set as account for person.
        accnt = Lna::Account.create!(account_hash) do |a|
          a.account_holder = person
        end
        add_to_warnings(NEW_ACCOUNT, "#{accnt.title} account for #{person.full_name}(#{netid})")
      
        # Make membership, belonging to org and person.
        mem_hash = clean_mem_hash(hash[:membership])
        mem = Lna::Membership.create!(mem_hash) do |m|
          m.person = person
          m.organization = org
          m.begin_date = Date.today
        end
        add_to_warnings(NEW_MEM, "'#{mem.title}' for #{person.full_name}(#{netid})")
        
        person.save
      end
      person  
    end
    
    #TODO: Move method to Lna::Organization?
    # @example Usage
    # org = { label: 'Library',
    #         code: 'LIB',
    #         alt_label: ['DCL']
    #       }
    # matching_organization(org)
    #
    def matching_organization(hash)
      orgs = Lna::Organization.where(hash)
      if orgs.count == 1
        return orgs.first
      elsif orgs.count == 0
        if hash_key? :code
          orgs = Lna::Organization.where(code: hash[:code])
          if orgs.count
          end
        end
      end
    end
    
    #TODO: When comparing make sure that its case insensitive. Might already be based on how .where
    # works.
    def find_or_create_org(hash)
      raise ArgumentError, 'Must have a label to find or create an organization.' unless hash[:label]
      
      orgs = Lna::Organization.where(hash) #probably throws errors too
      if orgs.count == 1
        return orgs.first
      elsif orgs.count == 0
        if hash.key? :code
          orgs = Lna::Organization.where(code: hash[:code])
          if orgs.count > 1
            raise "There are two organizations with #{hash[:code]} as their code."
          elsif orgs.count == 1
            # Trigger a change event here because data has changed.
            return orgs.first
          end
        end
        # If did not find the organization by code, create a new one.
        org = Lna::Organization.create!(hash) do |o|
          o.begin_date = Date.today
        end
        value = hash[:code] ? "#{hash[:label]}(#{hash[:code]})" : hash[:label]
        add_to_warnings(NEW_ORG, value)
        return org
      else
        raise "More than one organization matched the fields: #{hash.to_s}."
      end
    end
    
    # Removes :primary and :org keys from membership hash.
    def clean_mem_hash(hash)
      mem_hash = hash.clone
      mem_hash.delete_if { |key, value| [:org, :primary].include?(key) }
      mem_hash
    end
  end
end
