class Import < ActiveRecord::Base
  validates :load, :time_started, :time_ended, presence: true

  def self.last_successful_import(title)
    where(load: title, success: true)
      .order(time_started: :asc)
      .first
  end
end
