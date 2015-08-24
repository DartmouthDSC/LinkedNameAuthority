module Import
  
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
  def self.into_lna(hash = {})
    if hash.key?(:netid) && hash[:netid]
      into_lna_by_netid(hash[:netid], hash)
    else
      raise NotImplementedError, 'Can only import if netid is present.'
    end
  end

  # Creates or updates Lna objects for the person that has the given netid.
  #
  # @private
  #
  # @param netid [String] Dartmouth identifier
  # @param hash [Hash] hash containing  person, account and membership info
  # @return [Lna::Person] person that was created or updated
  def self.into_lna_by_netid(netid, hash = {})
    # Argument checking.
    if !hash[:person] && !hash[:membership]
      raise ArgumentError, 'Must have a :person or :membership key in hash.'
    elsif hash.key?(:membership) && !hash[:membership].key?(:org)
      raise ArgumentError, 'Membership must have an organization.'
    end
    
    account_hash = { account_name: netid }.merge(Lna::Account::DART_PROPERTIES)
    accounts = Lna::Account.where(account_hash)

    if accounts.count > 1
      raise "More than one account has the netid #{netid}."      
    elsif accounts.count == 1  # Update person.
      person = accounts.first.account_holder

      raise "Netid #{netid} is associated with a #{person.class}." unless person.is_a?(Lna::Person)

      # Update person record.
      person.update(hash[:person]) if hash[:person]

      # Update primary organization, if necessary.
      if hash[:membership][:primary]
        org = find_or_create_org(hash[:membership][:org])
        person.primary_org = org unless org.id == person.primary_org.id
        person.save
      end

      # Find matching memberships.
      # TODO: Case insensitve. 
      matching_mems = person.memberships.to_a.select do |m|
        m.title == hash[:membership][:title] &&
          m.organization.code == hash[:membership][:org][:code]
      end

      # Create or update memberships. Throw error if too many memberships matched.
      mem_hash = clean_mem_hash(hash[:membership])
      if matching_mems.count > 1
        raise 'More than one membership was a match for the given hash.'
      elsif matching_mems.count == 1
        matching_mems.first.update(mem_hash)
      else
        mem = Lna::Membership.create(mem_hash) do |m|
          m.person = person
          m.organization = find_or_create_org(hash[:membership][:org])
        end
        person.save!
        raise "#{mem.class} could not be saved because of the following error(s): " +
              "#{mem.errors.full_messages.join(", ")}" unless mem.persisted?
      end
    else   # Create new person.
      # Checking arguments.
      if !hash.key?(:membership) || !hash[:membership][:primary]
        raise ArgumentError, 'Primary membership required to create new person.'
      elsif !hash[:person]
        raise ArgumentError, 'Person hash required to create new person.'
      end
      
      # Find or create primary org.
      org = find_or_create_org(hash[:membership][:org])

      # Make person and set primary org.
      person = Lna::Person.create(hash[:person]) do |p|
        p.primary_org = org
      end
 
      raise "Lna::Person could not be saved because of the following error(s): " +
            "#{person.errors.full_messages.join(", ")}" unless person.persisted?

      # Make account and set as account for person.
      accnt = Lna::Account.create(account_hash) do |a|
        a.account_holder = person
      end

      raise "Lna::Account could not be saved because of the following error(s): " +
            "#{accnt.errors.full_messages.join(", ")}" unless accnt.persisted?
      
      # Make membership, belonging to org and person.
      mem_hash = clean_mem_hash(hash[:membership])
      mem = Lna::Membership.create(mem_hash) do |m|
        m.person = person
        m.organization = org
      end

      raise "Lna::Membership could not be saved because of the following error(s): " +
            "#{mem.errors.full_messages.join(", ")}" unless mem.persisted?
  
      person.save
    end
    #puts "Create person record for #{netid}."
    person  
  end
  private_class_method :into_lna_by_netid
  
  #TODO: Move method to Lna::Organization
  #TODO: When comparing make sure that its case insensitive. Might already be based on how .where
  # works.
  def self.find_or_create_org(hash)
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
      org = Lna::Organization.create(hash)
      raise "Lna::Organization could not be saved because of the following error(s): " +
            "#{org.errors.full_messages.join(", ")}" unless org.persisted?
      return org
    else
      raise "More than one organization matched the fields: #{hash.to_s}."
    end
  end
  private_class_method :find_or_create_org
  
  # Removes :primary and :org keys from membership hash.
  def self.clean_mem_hash(hash)
    mem_hash = hash.clone
    mem_hash.delete_if { |key, value| [:org, :primary].include?(key) }
    mem_hash
  end
  private_class_method :clean_mem_hash  
end
