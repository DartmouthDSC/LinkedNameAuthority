

# Log-in test user.
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
