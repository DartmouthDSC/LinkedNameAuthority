class OracleEmployee < ActiveRecord::Base

  establish_connection("oracle_#{Rails.env}".to_sym)

  self.table_name = 'DARTHR.DC_HR_ERIS_FACULTY_V'
####  self.table_name = 'lna_dc_hr_eris_faculty_v'
  self.primary_key = 'username'

end
