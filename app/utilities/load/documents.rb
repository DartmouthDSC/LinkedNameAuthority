module Load
  class Documents

    # Import publication records from Elements.
    #
    # 1. Query for all users that have been modified since the last time the import was done.
    # 2. Iterate through all the users for publications that have been modified since the last time
    #    the import was done.
    #      a. If no publications have been updated continue to the next user
    #      b. Otherwise, retrive the Lna::Person object for this person (if there is one).
    #          1. For each publication check if there is already a Lna::Collection::Document
    #             object.
    #          2. If there is already a record update it, if there isn't create a new record
    #             and attach it to the user.
    def self.from_elements
      
    end
    
  end
end
