# Based on production defaults.
require Rails.root.join("config/environments/production")

Rails.application.configure do
  config.relative_url_root = '/lna'
end
