require 'rails_helper'

RSpec.describe Lna::Account, type: :model do
  it 'has a valid factory' do
    orcid = FactoryGirl.create(:orcid_for_person)
    expect(orcid).to be_truthy
    orcid.account_holder.primary_org.destroy
    orcid.account_holder.destroy
  end

  describe  '.create' do
    before :context do
      @orcid = FactoryGirl.create(:orcid_for_person)
    end

    after :context do
      @orcid.account_holder.primary_org.destroy
      @orcid.account_holder.destroy
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
      orcid.account_holder.primary_org.destroy
      orcid.account_holder.destroy
    end

    it 'can be Lna::Organization' do
      orcid = FactoryGirl.create(:orcid_for_org)
      expect(orcid.account_holder).to be_a Lna::Organization
      orcid.account_holder.destroy
    end
  end

  describe 'validations' do
    before :example do
      @orcid = FactoryGirl.build(:orcid_for_person)
    end

    after :example do
      if @orcid.account_holder.is_a? Lna::Person
        @orcid.account_holder.primary_org.destroy
        @orcid.account_holder.destroy
      end
    end
    
    subject { @orcid }
    
    it 'assure account_holder is set' do
      subject.account_holder.primary_org.destroy
      subject.account_holder.destroy
      subject.account_holder = nil
      expect(subject.save).to be false
    end

    it 'assure account_holder is a person or organization' do
      subject.account_holder.primary_org.destroy
      subject.account_holder.destroy
      subject.account_holder = FactoryGirl.create(:orcid_for_org)
      expect(subject.save).to be false
      subject.account_holder.account_holder.destroy
    end
    
    it 'assure title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end
      
    it 'assure online account is set' do
      subject.online_account = nil
      expect(subject.save).to be false
    end
    
    it 'assure account name is set' do
      subject.account_name = nil
      expect(subject.save).to be false
    end
    
    it 'assure account service homepage is set' do
      subject.account_service_homepage = nil
      expect(subject.save).to be false
    end
  end

end
