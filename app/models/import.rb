class Import < ActiveRecord::Base
  validates :load, :time_started, :time_ended, presence: true
end
