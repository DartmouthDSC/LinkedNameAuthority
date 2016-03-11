require 'rails_helper'
require 'airborne'

RSpec.describe "Persons API", type: :request, https: true do
  include_context 'creates test person'

  describe 'GET persons/' do
    before :context do
      get persons_path, {}, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
    end
    
    it 'returns status code of 200' do
      expect_status :ok
    end

    it 'return content type of application/ld+json' do
      expect_header_contains('Content-Type', 'application/ld+json')
    end

    it 'returns graph with one person' do
      expect_json_sizes(:@graph => 2)
    end

    it 'includes email' do
      expect_json('@graph.0', :'foaf:mbox' => 'jane.a.doe@dartmouth.edu')
    end

    it 'includes @id' do
      expect_json('@graph.0', :@id => person_url(id: FedoraID.shorten(@jane.id)))
    end
    
    it 'includes given name' do
      expect_json('@graph.0', :'foaf:givenName' => 'Jane')
    end

    it 'includes primary org' do
      expect_json('@graph.0',
             :'org:reportsTo' => organization_url(id: FedoraID.shorten(@jane.primary_org.id)))
    end

    it 'includes link headers' do
      expect_header('Link', "<#{persons_url(page: 1)}>; rel=\"first\"")
    end
  end
  
  describe 'POST person/' do
    before :context do
      body = { 'foaf:familyName' => 'notDoe' }
      post persons_path, body.to_json, {
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
