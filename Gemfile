source 'https://rubygems.org'

gem 'rails', '4.2.4'

# Hydra dependencies
gem 'active-fedora', '~> 9.10.4'
# gem 'active-fedora',
#     github: 'projecthydra/active_fedora',
#     ref:    'e1391fb0dd4108923b02a3dfb344a19dd971a6f8'
gem 'active-triples', '~> 0.7.4'
# gem 'blacklight', '~> 5.16'
gem 'hydra-head', '~> 9.8.0'
gem 'ldp', '~> 0.5.0'
gem 'nokogiri', '~> 1.6.7'
gem 'nom-xml', '~> 0.5.1'
gem 'om', '~> 3.1.0'
gem 'rsolr', '~> 1.0.13'
gem 'solrizer', '~> 3.4.0'

gem 'devise'
gem 'dotenv-rails'
gem 'jbuilder', '~> 2.0'
gem 'omniauth-cas'
gem 'rdf-vocab'
gem 'turbolinks' # Turbolinks makes following links in your web application faster.
gem 'therubyracer', platforms: :ruby # Embed the V8 JavaScript interpreter into Ruby
gem 'whenever' # Used to run cron jobs.

# Database gems
group :oracle do 
  gem 'activerecord-oracle_enhanced-adapter', '~> 1.6.0'
  gem 'ruby-oci8' # Oracle
end
gem 'sqlite3' # used for ActiveRecord

# Asset Pipeline
# gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

group :development, :test, :ci do
  gem 'airborne'
  gem 'byebug'  # Call 'byebug' anywhere in the code to stop to get a debugger console.
  gem 'factory_girl_rails'
  gem 'pry-nav'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'spring'  # Spring speeds up development.
end

group :development do
  gem 'web-console', '2.3.0' # Can remove this once we go to ruby 2.2.2
  gem 'ruby-debug-passenger'
end

group :ci do
  gem 'coveralls', require: false
  gem 'fcrepo_wrapper', '~> 0.2.1'
  gem 'solr_wrapper', '~> 0.5.0'
end
