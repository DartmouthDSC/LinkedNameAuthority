require 'rails_helper'
require 'support/devise.rb'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do

  describe "GET cas" do

    let(:jane_hash) { FactoryGirl.create :omniauth_hash }
    
    before :all do
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    end

    before :each do
      request.env['omniauth.auth'] = jane_hash
      get :cas
      @jane = User.where(provider: :cas, uid: 'f12345f@dartmouth.edu').first
    end

    it 'creates new user in db' do
      expect(@jane.sign_in_count).to eql(1)
    end

    it 'displays correct message' do
      expect(flash[:notice]).to match(@jane.name)
    end
    
    it 'has correct netid in db' do
      expect(@jane.netid).to eql(jane_hash.extra.netid)
    end
    
    it 'increases count on second log-in' do
      sign_out @jane
      request.env['omniauth.auth'] = jane_hash
      get :cas
      user = User.where(provider: :cas, uid: 'f12345f@dartmouth.edu').first
      expect(user.sign_in_count).to eql(2)
    end
  end

end
