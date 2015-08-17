module Import

  DART_ACCOUNT = { account_name: 'Dartmouth',
                   online_account: 'www.dartmouth.edu',
                   account_service_homepage: 'dartdm.dartmouth.edu' }
 
  # Example:
  # lna_hash = { netid: 'd00000k',
  #              person: { full_name:   'Carla Galarza',
  #                        given_name:  'Carla',
  #                        family_name: 'Galarza',
  #                        mbox:        'Carla.M.Galarza@dartmouth.edu', },
  #              membership: { title: 'Programmer/Analyst' },
  #              organization: { label: 'Digital Library Technologies Group',
  #                              dept_code: 'DLTG' }
  #             }
  #                

  # Creates or updates Lna objects for the person described by the given hash.
  #
  # @param hash [Hash] can contain a person, account and membership information
  # @return [Lna::Person] person that was created or updated
  def self.to_lna(hash)
    account_hash = DART_ACCOUNT.clone
    account_hash[:account_name] = hash[:netid]
    
    dart_account = Lna::Account.where(account_hash).first ||
                   Lna::Account.new(account_hash)

    person = dart_account.account_holder
    
    unless person
      # Create account_holder, if there isn't one associated with the account.
      person = Lna::Person.new(hash[:person])
      #person.accounts << dart_account
      #dart_account.save
      #person.save
      # try to save or create and catch if it doesnt actually happen
    end    
    
    # Make sure its actually a person; accounts can be associated to orgs.
    unless person.is_a?(Lna::Person)
      raise "Netid #{dart_account.account_name} is not associated with a Lna::Person."
    end

    # Create the membership with the organization, if it doesn't already
    # exist.
    # A membership exist if it has the same title and the organization
    # with the same department name or department_code
    #if mem = person.memberships.where(hash.membership)
    #  if mem.organization.dept_code == hash.organization.dept_code
        # update mem
    #  end
    #end
    # try to find organization with dept code
    # try to find organization with label
    # create new organization
    # create a new membership

    person  
  end

end
