require File.expand_path(File.dirname(__FILE__) + "/environment")

# Use this file to easily define all of your cron jobs.

env :MAILTO, 'carlamgalarza@gmail.com'

CRON_LOG = "#{Rails.root}/log/cron.log"

# All output is written to cron.log and errors are emailed out.
set :output, lambda { "2>&1 >> #{CRON_LOG} | tee --append  #{CRON_LOG} " }

# Run oracle-faculty load once a day.
every 1.day, :at => '3:00 am' do
  rake "import:oracle-faculty"
end
