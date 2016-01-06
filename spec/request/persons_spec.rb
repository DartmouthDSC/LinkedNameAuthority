require 'rails_helper'
require 'airborne'
#require 'api_helpers'

RSpec.describe "Persons API", type: :request do
  include_context 'forces https requests'
  
  describe 'GET persons/' do
    before :context do
      get '/persons/1', {}, { content_type: 'application/ld+json' }
    end
    
    it 'returns status code of 200' do
      expect_status :success
    end

    it 'return content type of application/ld+json' do
      expect_header('Content-Type', 'application/ld+json')
    end
  end
  
  describe 'POST person/'
end
