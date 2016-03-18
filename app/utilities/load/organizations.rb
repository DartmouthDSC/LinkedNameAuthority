module Load
  class Organizations < Loader
    HR_ORG_IMPORT_TITLE = 'Organizations from HR Org view'
    
    # Keys for warnings hash.
    NEW_ORG = 'new organization'
    SENT_EMAIL = 'Sent email'
    
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
          'SUBUNIT' ].each do |orgType|
          Oracle::Organizations.find_by(org_type: orgType) do |org|
            loader.into_lna(org.to_hash);
          end
        end
      end
    end

#   Creates or updates Lna objects for the person described by the given hash.
#
#   @example Example of hash 
#     lna_hash = { 
#                  label: 'Library',
#                  alt_label: ['DLC']
#                  code:  'LIB'
#                }
#
#   @param hash [Hash] hash containing organization info
#   @return [Lna::Organization] organization that was created or updated
    def into_lna(hash = {})
      raise ArgumentError, 'Must have a label to find or create an organization.' unless hash[:label]

#     Probably throws errors too
      orgs = Lna::Organization.where(hash)
      if orgs.count == 1
        return orgs.first
      elsif orgs.count == 0
        if hash.key? :code
          orgs = Lna::Organization.where(code: hash[:code])
          if orgs.count > 1
            raise "There are two organizations with #{hash[:code]} as their code."
          elsif orgs.count == 1
#           Trigger a change event here because data has changed.
            return orgs.first
          end
        end
#       If did not find the organization by code, create a new one.
        org = Lna::Organization.create!(hash) do |o|
#	  EJB: Should be hash[:begin_date]...
          o.begin_date = Date.today
#         EJB: How to express org:hasSubOrganization/org:subOrganizationOf?
#         EJB: e.g.:
#         EJB: if hash[:type] == 'SCH'
#         EJB:   o. ... org:subOrganizationOf, hash[:division]
#         EJB: elsif hash[:type] == 'UNIT'
#         EJB:   o. ... org:subOrganizationOf, hash[:department]
#         EJB: elsif hash[:type] == 'DEPT'
#         EJB:   o. ... org:subOrganizationOf, hash[:sub_division]
#         EJB: ...
#         EJB: end
        end
        value = hash[:code] ? "#{hash[:label]}(#{hash[:code]})" : hash[:label]
        add_to_warnings(NEW_ORG, value)
        return org
      else
        raise "More than one organization matched the fields: #{hash.to_s}."
      end
    end

  end
end
