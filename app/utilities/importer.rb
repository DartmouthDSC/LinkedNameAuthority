class Importer
  # Keys for info hash
  NEW_ORG = 'Created new organization'
  NEW_PERSON = 'Created new person'
  NEW_MEM = 'Created new membership'
  NEW_ACCOUNT = 'Created new account'

  attr_reader :errors, :info
  attr_accessor :throw_errors, :emails
  
  # info = { NEW_ORG    => ['Anthropology[ANTH]'],
  #          NEW_PERSON => ['Jane Doe(d00000k)'],
  #          NEW_MEM
  #          NEW_ACCOUNT
  #        }
  #
  # errors = { 'Error one' => ['Jane Doe(d00000k)', 'd12345k'] }
  #
  # @param verbose [Boolean] 
  # @param emails [[String]] array of emails
  # @param throw_errors [Boolean] flag to throw errors after logging them
  def initialize(verbose = true, throw_errors = true, emails = []) 
    @verbose = verbose
    @emails = emails
    @throw_errors = throw_errors
    @errors = {}
    @info = {}

    # If verbose is set the errors and warnings will be displayed on the console or
    # emailed out if email address are given.

    # if verbose is false only errors will be displayed...
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
    #rescue NotImplementedError => e 
    #  errors[e.message] = hash #will not have a netid.
    # if its an argument error display the hash?  
    rescue Exception => e
      value = (hash[:person] && hash[:person][:full_name]) ?
                "#{hash[:person][:full_name]}(#{hash[:netid]})" :
                hash[:netid]

      @errors.key?(e.message) ?
        @errors[e.message] << value : #append.
        @errors[e.message] = [value]  #create new array.
      
      raise if @throw_errors
    end  
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
    elsif hash.key?(:membership) && !hash[:membership].key?(:org)
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
        person.primary_org = org unless org.id == person.primary_org.id
        person.save
      end

      # Create or update memberships.
      mem_hash = clean_mem_hash(hash[:membership])

      if mem = matching_membership(person, hash[:membership])
        mem.update(mem_hash)
      else
        mem = Lna::Membership.create(mem_hash) do |m|
          m.person = person
          m.organization = find_or_create_org(hash[:membership][:org])
        end
        person.save!
        raise "#{mem.class} could not be saved because of the following error(s): " +
              "#{mem.errors.full_messages.join(", ")}" unless mem.persisted?
        add_to_info(NEW_MEM, netid)
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

      add_to_info(NEW_PERSON, netid)
      
      # Make account and set as account for person.
      accnt = Lna::Account.create(account_hash) do |a|
        a.account_holder = person
      end
      
      raise "Lna::Account could not be saved because of the following error(s): " +
            "#{accnt.errors.full_messages.join(", ")}" unless accnt.persisted?

      add_to_info(NEW_ACCOUNT, netid)
      
      # Make membership, belonging to org and person.
      mem_hash = clean_mem_hash(hash[:membership])
      mem = Lna::Membership.create(mem_hash) do |m|
        m.person = person
        m.organization = org
      end

      raise "Lna::Membership could not be saved because of the following error(s): " +
            "#{mem.errors.full_messages.join(", ")}" unless mem.persisted?

      add_to_info(NEW_MEM, netid)
      
      person.save
    end
    #puts "Create person record for #{netid}."
    person  
  end
  
  #TODO: Move method to Lna::Organization
  #TODO: When comparing make sure that its case insensitive. Might already be based on how .where
  # works.
  def find_or_create_org(hash)
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
      add_to_info(NEW_ORG, hash[:label])
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

  def add_to_info(k, v)
    @info.key?(k) ? @info[k] << v : @info[k] = [v]
  end

  # Find memberships belonging to the person given that match the hash
  # returns matching membership or false if no memberships were found
  # @param person [Lna::Person]
  # TODO: could be moved into Lna::Person
  def matching_membership(person, mem_hash)
    #TODO: person is a Lna::Person    
    matching = person.memberships.to_a.select do |m|
      m.title.casecmp(mem_hash[:title]).zero? &&
        m.organization.code.casecmp(mem_hash[:org][:code]).zero?
    end

    raise 'More than one membership was a match for the given hash.' if matching.count > 1
    return matching.count == 1 ? matching.first : false
  end
end
