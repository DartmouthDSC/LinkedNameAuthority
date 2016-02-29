source 'https://rubygems.org'

gem 'rails', '4.2.4'

# Hydra dependencies
# Once the hydra gem is updated we should go back to using that.
# gem 'hydra', '9.1.0.rc1'
gem 'active-fedora', '~> 9.9.0'
gem 'active-triples', '~> 0.7.4'
# gem 'blacklight', '~> 5.16'
gem 'hydra-head', '~> 9.8.0'
gem 'ldp', '~> 0.4.1'
gem 'nokogiri', '~> 1.6.7'
gem 'nom-xml', '~> 0.5.1'
gem 'om', '~> 3.1.0'
gem 'rsolr', '~> 1.0.13'
gem 'solrizer', '~> 3.3.0'

gem 'airborne'
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
  gem 'factory_girl_rails'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'spring'  # Spring speeds up development.
end

group :development do
  gem 'byebug'  # Call 'byebug' anywhere in the code to stop to get a debugger console.
  gem 'web-console'
  gem 'ruby-debug-passenger'
end

group :ci do
  gem 'coveralls', require: false
  gem 'fcrepo_wrapper', '~> 0.2.1'
  gem 'solr_wrapper', '~> 0.5.0'
end
