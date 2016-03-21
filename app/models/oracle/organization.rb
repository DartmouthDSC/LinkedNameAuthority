module Oracle

  class Organizations < ActiveRecord::Base

    establish_connection("oracle_#{Rails.env}".to_sym)

    self.table_name = 'DARTHR.DC_ACAD_COMMONS_ORG_V'
#   Could be organization_id...
    self.primary_key = 'organization'

#   Here are the columns in this view:
##  ORGANIZATION	NOT NULL VARCHAR2(240)
##  ORG_LONG_NAME	VARCHAR2(150)
##  ORG_SHORT_CODE	VARCHAR2(150)
##  ORG_TYPE		VARCHAR2(30)
##  HB			VARCHAR2(80)
##  GL_ORG_VALUE	VARCHAR2(150)
##  DIVISION		VARCHAR2(4000 CHAR)
##  SCHOOL		VARCHAR2(4000 CHAR)
##  SUB_DIVISION	VARCHAR2(4000 CHAR)
##  DEPARTMENT		VARCHAR2(4000 CHAR)
##  UNIT		VARCHAR2(4000 CHAR)
##  SUB_UNIT		VARCHAR2(4000 CHAR)
##  ORG_BEGIN_DATE	NOT NULL DATE
##  ORG_END_DATE	DATE
##  LAST_SYSTEM_UPDATE	DATE
##  ORGANIZATION_ID	NOT NULL NUMBER(15)


#   Return a hash in a connonical form for the LNA ImportController.
    def to_hash
      
      unless (self.organization)
        raise ArgumentError.new("#{self.organization_id}: No Organization (#{self})")
      end

#     Our full hash.
      hash = { :label        => self.organization,
               :org_id       => self.organization_id,
               :long_name    => self.org_long_name,
               :code         => self.org_short_code,
               :type         => self.org_type,
               :hb           => self.hb,
               :gl_org_value => self.gl_org_value,
               :division     => self.division,
               :school       => self.school,
               :sub_division => self.sub_division,
               :department   => self.department,
               :unit         => self.unit,
               :sub_unit     => self.sub_unit,
               :begin_date   => self.org_begin_date,
               :end_date     => self.org_end_date,
               :update_date  => self.last_system_update,
      }

#     Until we build out the LNA ImportController, we ditch fields
#     that model doesn't know about.
####      [ :prop_id,
####        :initials,
####        :known_as,
####        :rank,
####        :primary_group
####      ].each do |key|
####        hash.delete(key)
####      end

#     Return our (reduced) hash.
      return hash
      
    end

  end

end
