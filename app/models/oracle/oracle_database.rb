module Oracle
  class OracleDatabase < ActiveRecord::Base
    self.abstract_class = true
    establish_connection("oracle_#{Rails.env}".to_sym)
  end
end
