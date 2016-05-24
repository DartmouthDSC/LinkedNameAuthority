source 'https://rubygems.org'

gem 'rails', '4.2.6'

# Hydra dependencies
gem 'active-fedora', '~> 9.12.0'
gem 'active-triples', '~> 0.7.4'
gem 'hydra-head', '~> 9.10.0'
gem 'ldp', '~> 0.5.0'
gem 'nokogiri', '~> 1.6.7'
gem 'nom-xml', '~> 0.5.1'
gem 'om', '~> 3.1.0'
gem 'rsolr', '~> 1.0.13'
gem 'solrizer', '~> 3.4.0'

gem 'devise'
gem 'dotenv-rails'
gem 'gaffe'
gem 'hydra-role-management'
gem 'jbuilder', '~> 2.0'
gem 'net-dnd', github: 'dartmouth-dltg/net-dnd'
gem 'omniauth-cas'
gem 'pg'
gem 'rdf-vocab'
gem 'turbolinks' # Turbolinks makes following links in your web application faster.
gem 'therubyracer', platforms: :ruby # Embed the V8 JavaScript interpreter into Ruby
gem 'whenever' # Used to run cron jobs.

group :oracle do 
  gem 'activerecord-oracle_enhanced-adapter', '~> 1.6.0'
  gem 'ruby-oci8' # Oracle
end

# Asset Pipeline
# gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

group :development, :test, :ci do
  gem 'airborne'
  gem 'byebug'  # Call 'byebug' anywhere in the code to stop to get a debugger console.
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'pry-nav'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'spring'  # Spring speeds up development.
end

group :development do
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
  gem 'ruby-debug-passenger'
  gem 'web-console', '2.3.0' # Can remove this once we go to ruby 2.2.2
end

group :ci do
  gem 'coveralls', require: false
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper'
end
