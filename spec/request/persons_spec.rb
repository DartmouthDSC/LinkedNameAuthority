require 'rails_helper'

RSpec.describe "Persons API", type: :request do
  describe 'GET persons/' do
    before(:context) do
      https!
      get '/persons/1', { format: :jsonld }
    end
    
    it 'returns status code of 200' do
      expect(response).to be_success
    end

    it 'return content type of application/ld+json' do
      expect(response.content_type).to eq 'application/ld+json'
    end

    it 'redirects to page 1'
  end
  
  describe 'POST person/'
end
