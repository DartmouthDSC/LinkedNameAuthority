require 'rails_helper'
require 'airborne'

RSpec.describe "Organizations API", type: :request do
  include_context 'forces https requests'

  before :context do 
    @org = FactoryGirl.create(:thayer)
  end

  after :context do
    @org.destroy
  end
  
  describe 'GET organizations/' do
    before :context do
      get organizations_path, format: :jsonld
    end

    it 'return status code of 200' do
      expect_status :ok
    end

    it 'returns graph with one organization' do
      expect_json_sizes(:@graph => 1)
    end

    it 'returns identifier' do
      expect_json('@graph.0', :'org:identifier' => @org.code)
    end
    
    it 'returns sub organizations' do
      expect_json('@graph.0', :'org:subOrganizationOf' => [])
    end
    
    it 'returns pref label' do
      expect_json('@graph.0', :'skos:prefLabel' => @org.label)
    end
    
    it 'return alt label' do
      expect_json('@graph.0', :'skos:altLabel' => @org.alt_label)
    end

    it 'includes link headers' do
      expect_header('Link', "<#{organizations_url(page: 1)}>; ref=\"first\"")
    end
  end

  describe 'POST organizations/' do
    before :context do
      body = { 'org:identifier' => 'its' }
      post organizations_path, body.to_json, {
             'ACCEPT' => 'application/ld+json',
             'CONTENT_TYPE' => 'application/ld+json'
           }
    end

    it 'returns status code of 200' do
      expect_status :ok
    end

    it 'searches a different identifier and returns 0 results' do
      expect_json_sizes(:@graph => 0)
    end
  end
end
