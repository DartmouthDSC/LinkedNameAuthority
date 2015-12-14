require 'rails_helper'

RSpec.describe 'OmniAuth integration', :type => :request do
  before :all do
    OmniAuth.config.test_mode = true
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
    https!
  end

  before :each do
    OmniAuth.config.mock_auth[:cas] = nil
  end

  it 'redirected from /sign-in' do
    get '/sign_in'
    expect(response).to redirect_to '/users/auth/cas'
  end

  it 'can log in' do
    jane = FactoryGirl.create(:omniauth_hash)
    OmniAuth.config.mock_auth[:cas] = jane
    get_via_redirect '/users/auth/cas'
    expect(response.body).to include(I18n.t 'devise.omniauth_callbacks.success', name: jane.info.name)
  end

  context 'when user logs out' do
    before :each do
      get '/sign_out'
    end

    it 'redirects to Dartmouth logout page' do
      expect(response.location).to match 'https://login.dartmouth.edu/logout.php'
    end

    it 'has link to root in redirect page' do
      expect(response.body).to include root_url
    end

    it 'does terminate session' do
      get '/'
      expect(response.body).to include(I18n.t 'devise.sessions.signed_out')
     end  
  end
  
  it 'redirects on authentication error' do
    OmniAuth.config.mock_auth[:cas] = :invalid_credentials
    get '/users/auth/cas'
    follow_redirect!
    expect(response).to redirect_to '/sign_in'
  end

end
