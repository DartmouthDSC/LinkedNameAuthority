module Oracle

  class Faculty < ActiveRecord::Base

    establish_connection("oracle_#{Rails.env}".to_sym)

    self.table_name = 'DARTHR.DC_HR_ERIS_FACULTY_V'
    self.primary_key = 'username'

#   Here are the columns in this view:
##  USERNAME    VARCHAR2(150)
##  EMAIL    VARCHAR2(256 CHAR)
##  PROPRIETARY_ID     VARCHAR2(150)
##  FIRSTNAME    VARCHAR2(150)
##  LASTNAME   NOT NULL VARCHAR2(150)
##  INITIALS    VARCHAR2(6)
##  SUFFIX     VARCHAR2(30)
##  KNOWNAS    VARCHAR2(150)
##  POSITION    VARCHAR2(240)
##  RANK    VARCHAR2(150)
##  DEPARTMENT    VARCHAR2(4000 CHAR)
##  DEPARTMENT_CODE    VARCHAR2(4000 CHAR)
##  PRIMARYGROUPDESCRIPTOR     VARCHAR2(4000 CHAR)

#   Return a hash in a connonical form for the LNA ImportController.
    def to_hash
      
      unless (self.username)
        raise ArgumentError.new("#{self.lastname}: No NetID (#{self})")
      end

#     Generate a person's full name.
      nameParts = []
#     See if we have a first name to work with.
      if ((firstname = self.firstname))
#	If there are multiple parts to the first name, work through them.
        if ((firsts = firstname.split(' ')) && firsts.count > 1)
          firsts.each do |part|
#	    If true the person has an initial as part of their first
#	    name, so we want to append a period to it.
            if (part.length == 1 && part.upcase == part)
              part.concat('.')
            end
          end
#	  Put their first name back together.
          firstname = firsts.join(' ')
        end
      end
      nameParts.push(firstname) if (firstname)
#     The initials field includes the initial of the first name, so we
#     skip it in constructing the full name.
      if (self.initials[1..-1] != '')
        nameParts.push(self.initials[1..-1].split(//).join('.') + '.')
      end
      nameParts.push(self.lastname)
      nameParts.push(self.suffix) if (self.suffix)

#     Our full hash.
      hash = { :netid         => self.username,
               :person        => {
                                   :given_name  => firstname,
                                   :family_name => self.lastname,
                                   :full_name   => nameParts.join(' '),
                                   :mbox        => self.email,
                                 },
               :membership    => {
                                   :primary => true,
                                   :title   => self.position,
                                   :org     => {
                                                 :label => self.department,
                                                 :code  => self.department_code,
                                               }
                                 },
               :prop_id       => self.proprietary_id,
               :initials      => self.initials,
               :known_as      => self.knownas,
               :rank          => self.rank,
               :primary_group => self.primarygroupdescriptor,
      }

#     Until we build out the LNA ImportController, we ditch fields
#     that model doesn't know about.
      [ :prop_id,
        :initials,
        :known_as,
        :rank,
        :primary_group
      ].each do |key|
        hash.delete(key)
      end

#     Return our (reduced) hash.
      return hash
      
    end

  end

end