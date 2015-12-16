

# Log-in test user in before context and log out in after context.
RSpec.shared_context 'authenticate user' do
  before :all do
    OmniAuth.config.test_mode = true
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
    OmniAuth.config.mock_auth[:cas] = FactoryGirl.create(:omniauth_hash)
    get_via_redirect '/sign_in'
  end

  after :all do
    get '/sign_out'
  end
end


RSpec.shared_examples 'successful POST request' do
  it 'returns 201 status code' do
    expect(response).to have_http_status(:created)
  end
end


RSpec.shared_examples 'successful request' do
  it 'returns 200 status code' do
    expect(response).to be_success
  end
end


RSpec.shared_examples 'requires authentication' do  
  describe 'when not authenticated' do
    it 'returns 401 status code' do
      send action, path, { format: :jsonld }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
