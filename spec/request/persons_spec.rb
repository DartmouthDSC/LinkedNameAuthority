require 'rails_helper'
require 'airborne'

RSpec.describe "Persons API", type: :request do
  include_context 'forces https requests'
  include_context 'creates test person'

  describe 'GET persons/' do
    before :context do
      get '/persons', {}, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
    end
    
    it 'returns status code of 200' do
      expect_status :ok
    end

    it 'return content type of application/ld+json' do
      expect_header_contains('Content-Type', 'application/ld+json')
    end

    it 'response includes graph with one person' do
      expect_json('@graph.0', :'foaf:givenName' => 'Jane',
                  :'foaf:mbox' => 'jane.a.doe@dartmouth.edu')
    end

    it 'includes link headers' do
      expect_header('Link', "<#{root_url}persons/1>; ref=\"first\"")
    end
  end
  
  describe 'POST person/' do
    before :context do
      body = { 'foaf:familyName' => 'notDoe' }
      post '/persons', body.to_json, {
             'ACCEPT' => 'application/ld+json',
             'CONTENT_TYPE' => 'application/ld+json'
           }
    end
    
    it 'return status code of 200' do
      expect_status :ok
    end

    it 'search different last name returns 0 results' do
      expect_json_sizes(:@graph => 0)
    end
  end
end
