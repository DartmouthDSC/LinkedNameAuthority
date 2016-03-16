class Import < ActiveRecord::Base
  validates :load, :time_started, :time_ended, :success, presence: true
end
