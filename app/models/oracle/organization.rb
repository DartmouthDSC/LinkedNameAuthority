module Oracle
  class Organization < OracleDatabase
    # Org types ordered from lowest to highest in the hierarchy.
    ORDERED_ORG_TYPES = [ 'SUBUNIT', 'UNIT', 'DEPT', 'SUBDIV', 'ACAD DIV', 'SCH', 'DIV'].freeze

    self.table_name = 'DARTHR.DC_ACAD_COMMONS_ORG_V'
    self.primary_key = 'organization' # Could be organization_id...

    set_date_columns :org_begin_date, :org_end_date, :last_system_update
    
    # Limit results by type.
    scope :type, -> (t) { where(org_type: t) }

    # Limit results to organization ended before or on today.
    scope :ended, -> { where('org_end_date <= ?', Date.today) }

    # Limit results to records modified on or after the date given
    def self.modified_since(d)
      if d.nil?
        return all
      elsif d.respond_to?(:to_date)
        d = d.to_date
      end
      where('last_system_update >= ?', d)
    end
    

    # Return a hash in a connonical form for the Lna Organization Loader.
    def to_hash
      unless (self.organization)
        raise ArgumentError.new("#{self.organization_id}: No Organization (#{self})")
      end

      # Deduce the super organization.
      super_org = case self.org_type
                  when 'SCH'
                    self.division
                  when 'ACAD DIV'
                    self.school
                  else
                    map_types = {
                      'DIV'      => self.division,
                      'SCH'      => self.school,
                      'ACAD DIV' => nil,
                      'SUBDIV'   => self.sub_division,
                      'DEPT'     => self.department,
                      'UNIT'     => self.unit,
                      'SUBUNIT'  => self.sub_unit
                    }
                    super_types = ORDERED_ORG_TYPES.drop_while { |t| t != self.org_type }.drop(1)
                    super_types.map { |t| map_types[t] }.compact.first
                  end
      
      {
        label:              self.organization,
        hr_id:              self.organization_id.to_s,
        alt_label:          [self.org_long_name, self.org_short_code].uniq,
        kind:               self.org_type,
        hinman_box:         self.hb,
        super_organization: (super_org) ? { label: super_org } : nil,
        begin_date:         self.org_begin_date.to_s,
        end_date:           self.org_end_date.to_s,
      }
    end
  end
end
