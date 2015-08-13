module Oracle

  class Faculty < ActiveRecord::Base

    establish_connection("oracle_#{Rails.env}".to_sym)

    self.table_name = 'DARTHR.DC_HR_ERIS_FACULTY_V'
    self.primary_key = 'username'

#   Return a hash with a connonical form for Lna::Person to import.
    def to_hash
####  USERNAME    VARCHAR2(150)
####  EMAIL    VARCHAR2(256 CHAR)
####  PROPRIETARY_ID     VARCHAR2(150)
####  FIRSTNAME    VARCHAR2(150)
####  LASTNAME   NOT NULL VARCHAR2(150)
####  INITIALS    VARCHAR2(6)
####  SUFFIX     VARCHAR2(30)
####  KNOWNAS    VARCHAR2(150)
####  POSITION    VARCHAR2(240)
####  RANK    VARCHAR2(150)
####  DEPARTMENT    VARCHAR2(4000 CHAR)
####  DEPARTMENT_CODE    VARCHAR2(4000 CHAR)
####  PRIMARYGROUPDESCRIPTOR     VARCHAR2(4000 CHAR)
      nameParts = []
      nameParts.push(self.firstname) if (self.firstname)
      if (self.initials[1..-1])
        nameParts.push(self.initials[1..-1].split(//).join('.') + '.')
      end
      nameParts.push(self.lastname)
      nameParts.push(self.suffix) if (self.suffix)
      return { :netid         => self.username,
               :mbox          => self.email,
               :prop_id       => self.proprietary_id,
               :given_name    => self.firstname,
               :initials      => self.initials,
               :family_name   => self.lastname,
               :full_name     => nameParts.join(' '),
               :known_as      => self.knownas,
               :rank          => self.rank,
               :title         => self.position,
               :department    => self.department,
               :dept_code     => self.department_code,
               :primary_group => self.primarygroupdescriptor,
      }
    end

  end

end
