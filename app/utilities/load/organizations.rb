module Load
  class Organizations < Loader
    HR_ORG_IMPORT_TITLE = 'Organizations from HR Org view'
    
    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    SENT_EMAIL = 'Sent email'
    
##  ORG_TYPE  COUNT(ORG_TYPE)
##  -------------------------
##  TPP       2
##  SCH       4
##  DIV       5
##  ACAD DIV  7
##  SUBDIV    13
##  SUBUNIT   99
##  DEPT      217
##  UNIT      348
    
    def self.from_hr
      batch_load(title: HR_ORG_IMPORT_TITLE,
                 verbose: true,
                 throw_errors: false,
                 emails: ENV['IMPORTER_EMAIL_NOTICES']) do |loader|
        [ 'DIV',
          'ACAD DIV',
          'SCH',
          'SUBDIV',
          'DEPT',
          'UNIT',
          'SUBUNIT',
          'TPP' ].each do |orgType|
          Oracle::Organizations.find_by(org_type: orgType) do |org|
            loader.into_lna(org.to_hash);
          end
        end
      end
    end

#   Creates or updates Lna objects for the person described by the given hash.
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
###   EJB
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

  end
end
