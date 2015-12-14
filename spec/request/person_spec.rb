require 'rails_helper'

# Note: These test must be run in the order that they are written.
RSpec.describe "Person API", type: :request do
  before :all do
    https!
  end

  shared_context 'authenticate user' do
    before :all do 
      OmniAuth.config.test_mode = true
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
      Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
      OmniAuth.config.mock_auth[:cas] = FactoryGirl.create(:omniauth_hash)
      get_via_redirect '/sign_in'
    end
  end
  
  describe 'POST person/' do
    it 'returns error if user is not authenticated' do
      post '/person', { format: :jsonld }
      expect(response).not_to be_success
    end

    describe 'when user is authenticated' do
      include_context 'authenticate user'
    
      it 'returns status code of 200' do
        post '/person', { format: :jsonld }
        expect(response).to be_success
      end
    end
  end

  describe 'GET person/' do
    before(:context) do
      get '/person/1', { format: :jsonld }
    end
    
    it 'returns status code of 200' do
      expect(response).to be_success
    end

    it 'return content type of application/ld+json' do
      expect(response.content_type).to eq 'application/ld+json'
    end

    it 'redirects to page 1'
  end
end
