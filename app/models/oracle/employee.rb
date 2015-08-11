module Oracle

  class Employee < ActiveRecord::Base

    establish_connection("oracle_#{Rails.env}".to_sym)

    self.table_name = 'DARTHR.DC_HR_ERIS_FACULTY_V'
    self.primary_key = 'username'

#   Return a hash with a connonical form for Lna::Person to import.
    def to_hash
####  PROPRIETARY_ID     VARCHAR2(150)
####  PRIMARYGROUPDESCRIPTOR     VARCHAR2(4000 CHAR)
####  POSITION    VARCHAR2(240)
####  RANK    VARCHAR2(150)
####  DEPARTMENT    VARCHAR2(4000 CHAR)
####  DEPARTMENT_CODE    VARCHAR2(4000 CHAR)
####  KNOWNAS    VARCHAR2(150)

####  EMAIL    VARCHAR2(256 CHAR)
####  USERNAME    VARCHAR2(150)
####  FIRSTNAME    VARCHAR2(150)
####  LASTNAME   NOT NULL VARCHAR2(150)
####  INITIALS    VARCHAR2(6)
####  SUFFIX     VARCHAR2(30)
      return { :netid       => self.username,
               :given_name  => self.firstname,
               :family_name => self.lastname,
               :full_name   => [ self.firstname,
                                 self.initials,
                                 self.lastname ].join(' ') +
                               ((self.suffix) ? ', ' + self.suffix : ''),
               :title       => self.position,
               :mbox        => self.email, }
    end

  end

end
