require File.expand_path(File.dirname(__FILE__) + "/environment")

# Use this file to easily define all of your cron jobs.

# Cron log path.
CRON_LOG = "#{Rails.root}/log/cron.log"

# Where error emails will be sent.
env :MAILTO, ENV['CRON_EMAIL_NOTICES']

# Set environment based on environmental variable otherwise will always default to production.
set :environment, "#{Rails.env}"

# All output is written to cron.log and errors are emailed out.
set :output, lambda { "2>&1 >> #{CRON_LOG} | tee --append  #{CRON_LOG}" }

# Run oracle-faculty load once a day.
every 1.day, :at => '10:00 am' do
  rake "load:all"
end
