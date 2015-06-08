require 'rails_helper'

RSpec.describe :LnaAccount, :type => :model do
  
  it 'has a valid factory' do
    orcid = FactoryGirl.create(:lna_account)
    expect(orcid).to be_truthy
    orcid.destroy
  end

  context 'when LnaAccount created' do
    before :all do
      @orcid = FactoryGirl.create(:lna_account)
    end

    it 'is a LnaAccount' do
      expect(@orcid).to be_instance_of LnaAccount
    end

    it 'is an ActiveFedora record' do
      expect(@orcid).to be_kind_of ActiveFedora::Base
    end
    
    it 'has title' do
      expect(@orcid.dc_title).to eql 'Orcid'
    end
    
    it 'has online account' do
      expect(@orcid.foaf_online_account).to eql 'http://orcid.org/0000-000-0000'
    end
    
    it 'has account name' do
      expect(@orcid.foaf_account_name).to eql '0000-000-0000'
    end
    
    it 'has account service homepage' do
      expect(@orcid.foaf_account_service_homepage).to eql 'http://orcid.org'
    end

    after :all do
      @orcid.destroy
    end
  end

  context 'when validating' do
    before :all do
      @orcid = FactoryGirl.build(:lna_account)
    end
    
    it 'assures title is set' do
      @orcid.dc_title = nil
      expect(@orcid.save).to be false
    end
      
    it 'assures online account is set' do
      @orcid.foaf_online_account = nil
      expect(@orcid.save).to be false
    end
    
    it 'assures account name' do
      @orcid.foaf_account_name = nil
      expect(@orcid.save).to be false
    end
    
    it 'assures account service homepage' do
      @orcid.foaf_account_service_homepage = nil
      expect(@orcid.save).to be false
    end
  end

end
