require 'rails_helper'

RSpec.describe Lna::Account, type: :model do
  
  it 'has a valid factory' do
    orcid = FactoryGirl.create(:orcid)
    expect(orcid).to be_truthy
    orcid.destroy
  end

  context 'when Lna::Account created' do
    before :all do
      @orcid = FactoryGirl.create(:orcid)
    end

    it 'is a Lna::Account' do
      expect(@orcid).to be_instance_of Lna::Account
    end

    it 'is an ActiveFedora record' do
      expect(@orcid).to be_kind_of ActiveFedora::Base
    end
    
    it 'has title' do
      expect(@orcid.title).to eql 'Orcid'
    end
    
    it 'has online account' do
      expect(@orcid.online_account).to eql 'http://orcid.org/0000-000-0000'
    end
    
    it 'has account name' do
      expect(@orcid.account_name).to eql '0000-000-0000'
    end
    
    it 'has account service homepage' do
      expect(@orcid.account_service_homepage).to eql 'http://orcid.org'
    end

    after :all do
      @orcid.destroy
    end
  end

  context 'when validating' do
    before :all do
      @orcid = FactoryGirl.build(:orcid)
    end

    it 'assures Lna::Person is set'
    
    it 'assures title is set' do
      @orcid.title = nil
      expect(@orcid.save).to be false
    end
      
    it 'assures online account is set' do
      @orcid.online_account = nil
      expect(@orcid.save).to be false
    end
    
    it 'assures account name' do
      @orcid.account_name = nil
      expect(@orcid.save).to be false
    end
    
    it 'assures account service homepage' do
      @orcid.account_service_homepage = nil
      expect(@orcid.save).to be false
    end
  end

end
