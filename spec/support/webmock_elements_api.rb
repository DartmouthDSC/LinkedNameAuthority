# Helpers to create webmock stubs for querying the Symplectic Elements API.
# Methods inspired from https://github.com/sferik/twitter

# Opens fixture, as all fixtures are sample api responses.
def fixture(file)
  fixture_path = File.expand_path('../../fixtures', __FILE__)
  File.new(File.join(fixture_path, file))
end

# Creates stub request for elements api. Reads in credentials and api root from elements
# config file, located at `config/elements.yml`.
def stub_get_elements(path, query: nil)
  config = Symplectic::Elements::Api.config
  
  stub_request(:get, config[:api_root] + path)
    .with(query: query, basic_auth: [config[:username], config[:password]],
          headers: { 'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.2' })
end

# Helper to check resquests for elements api. 
def a_get_elements(path, query: nil)
  config = Symplectic::Elements::Api.config
  
  a_request(:get, config[:api_root] + path)
    .with(query: query, basic_auth: [config[:username], config[:password]],
          headers: { 'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.2' })
end

