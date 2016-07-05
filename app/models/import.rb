class Import < ActiveRecord::Base
  validates :load, :time_started, :time_ended, presence: true

  # Returns time of last successful (no errors) import, for load with the
  # corresponding title.
  #
  # @param [String] title of load
  # @return [Time] if there is a last successful load return time
  # @return [nil] if there is not a last successful load return nil
  def self.last_successful_import(title)
    result = where(load: title, success: true)
              .order(time_started: :desc)
              .first
    (result) ? result.time_started : nil
  end
end
