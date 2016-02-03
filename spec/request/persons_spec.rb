require 'rails_helper'
require 'airborne'

RSpec.describe "Persons API", type: :request do
  include_context 'forces https requests'
  
  describe 'GET persons/' do
    before :context do
      get '/persons', {}, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
    end
    
    it 'returns status code of 200' do
      expect_status(:ok)
    end

    it 'return content type of application/ld+json' do
      expect_header_contains('Content-Type', 'application/ld+json')
    end
  end
  
  describe 'POST person/'
end
