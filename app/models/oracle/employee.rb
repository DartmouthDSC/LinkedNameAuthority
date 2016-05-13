module Oracle
  class Employee < OracleDatabase
    self.table_name = 'DARTHR.DC_ACAD_COMMONS_EMP_V'
    self.primary_key = 'netid'

#   Here are the columns in this view:
##  INITIALS           VARCHAR2(6)
##  FIRST_NAME         VARCHAR2(150)
##  LAST_NAME          NOT NULL VARCHAR2(150)
##  SUFFIX             VARCHAR2(30)
##  EMAIL              VARCHAR2(256 CHAR)
##  NETID              VARCHAR2(150)
##  SCHOOL             VARCHAR2(4000 CHAR)
##  TITLE              VARCHAR2(484)
##  FACULTY_RANK       VARCHAR2(150)
##  DEPARTMENT         NOT NULL VARCHAR2(240)
##  DEPARTMENT_ID      NOT NULL NUMBER(15)
##  KNOWNAS            VARCHAR2(150)
##  PERSON_ID          NOT NULL NUMBER(10)
##  LASTEST_START_DATE NOT NULL DATE
##  SCHOOL_START_DATE  DATE
##  DEPT_START_DATE    DATE
##  PRIMARY_FLAG       VARCHAR2(1 CHAR)
##  LAST_MODIFIED_DATE DATE

#   Return a hash in a connonical form for the Lna Person Loader.
    def to_hash
      unless (self.netid)
        raise ArgumentError.new("#{self.last_name}: No NetID (#{self})")
      end

#     Generate a person's full name.
      nameParts = []
#     See if we have a first name to work with.
      if ((firstname = self.first_name))
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
      nameParts.push(self.last_name)
      nameParts.push(self.suffix) if (self.suffix)

#     Our full hash.
      {
        netid: self.netid,
        person: {
          given_name:  firstname,
          family_name: self.last_name,
          full_name:   nameParts.join(' '),
          mbox:        self.email,
        },
        membership: {
          primary: (self.primary_flag == 'Y' || self.primary_flag == 'y'),
          title:   self.title,
          org:     {
            label: self.department,
            hr_id: self.department_id.to_s,
          },
          begin_date: self.dept_start_date || self.latest_start_date
        }
      }
    end

    # Filter out employees with title of Non-Paid, Temporary and nil.
    def self.with_title
      where.not({ title: ['Temporary', 'Non-Paid', nil] })
    end

    def self.primary
      where({ primary_flag: ['Y', 'y'] })
    end

    def self.not_primary
      self.primary.not
    end
  end
end
