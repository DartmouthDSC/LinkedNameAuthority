source 'https://rubygems.org'

gem 'rails', '4.2.4'

# Hydra dependencies
# Once the hydra gem is updated we should go back to using that.
# gem 'hydra', '9.1.0.rc1'
gem 'active-fedora', '~> 9.5.0'
gem 'active-triples', '~> 0.7.0'
gem 'blacklight', '~> 5.13.1'
gem 'hydra-head', '~> 9.1.4'
gem 'ldp', '~> 0.4.0'
gem 'nokogiri', '~> 1.6.5'
gem 'nom-xml', '~> 0.5.1'
gem 'om', '~> 3.1.0'
gem 'rsolr', '~> 1.0.10'
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
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

group :development, :test, :ci do
  gem 'byebug'  # Call 'byebug' anywhere in the code to stop to get a debugger console.
  gem 'factory_girl_rails'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'ruby-debug-passenger'
  gem 'spring'  # Spring speeds up development.
  gem 'web-console', '~> 2.0' # Access an IRB console on exception pages.
end

group :ci do
  gem 'fcrepo_wrapper', '~> 0.1'
  gem 'solr_wrapper', '~> 0.4'
end
