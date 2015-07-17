require 'rails_helper'

RSpec.describe Lna::Account, type: :model do
  it 'has a valid factory' do
    orcid = FactoryGirl.create(:orcid_for_person)
    expect(orcid).to be_truthy
    orcid.destroy
  end

  describe  '.create' do
    before :context do
      @orcid = FactoryGirl.create(:orcid_for_person)
    end

    after :all do
      @orcid.destroy
    end

    subject { @orcid }
    
    it { is_expected.to be_instance_of Lna::Account }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'sets title' do
      expect(subject.title).to eql 'Orcid'
    end
    
    it 'sets online account' do
      expect(subject.online_account).to eql 'http://orcid.org/0000-000-0000'
    end
    
    it 'sets account name' do
      expect(subject.account_name).to eql '0000-000-0000'
    end
    
    it 'sets account service homepage' do
      expect(subject.account_service_homepage).to eql 'http://orcid.org'
    end
  end

  describe '#account_holder' do
    it 'can be Lna::Person' do
      orcid = FactoryGirl.create(:orcid_for_person)
      expect(orcid.account_holder).to be_a Lna::Person
      orcid.destroy
    end

    it 'can be Lna::Organization' do
      orcid = FactoryGirl.create(:orcid_for_org)
      expect(orcid.account_holder).to be_a Lna::Organization
      orcid.destroy
    end
  end

  describe 'validations' do
    before :example do
      @orcid = FactoryGirl.build(:orcid_for_person)
    end

    subject { @orcid }
    
    it 'assures account_holder is set' do
      subject.account_holder = nil
      expect(subject.save).to be false
    end
    
    it 'assures title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end
      
    it 'assures online account is set' do
      subject.online_account = nil
      expect(subject.save).to be false
    end
    
    it 'assures account name' do
      subject.account_name = nil
      expect(subject.save).to be false
    end
    
    it 'assures account service homepage' do
      subject.account_service_homepage = nil
      expect(subject.save).to be false
    end
  end

end
