require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do

  before :all do
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
  end
  
  it 'can redirect to /sign_in' do
    get :new
    expect(response).to redirect_to '/users/auth/cas'
  end
end
