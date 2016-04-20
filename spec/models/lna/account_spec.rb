require 'rails_helper'

RSpec.describe Lna::Account, type: :model do
  it 'has a valid factory' do
    orcid = FactoryGirl.create(:orcid_for_person)
    expect(orcid).to be_truthy
    id = orcid.account_holder.primary_org.id
    orcid.account_holder.destroy
    Lna::Organization.find(id).destroy
  end

  describe  '.create' do
    before :context do
      @orcid = FactoryGirl.create(:orcid_for_person)
    end

    after :context do
      id = @orcid.account_holder.primary_org.id
      @orcid.account_holder.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @orcid }
    
    it { is_expected.to be_instance_of Lna::Account }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'sets title' do
      expect(subject.title).to eql 'ORCID'
    end
        
    it 'sets account name' do
      expect(subject.account_name).to eql 'http://orcid.org/0000-000-0000'
    end
    
    it 'sets account service homepage' do
      expect(subject.account_service_homepage).to eql 'http://orcid.org'
    end
  end

  describe '#account_holder' do
    it 'can be Lna::Person' do
      orcid = FactoryGirl.create(:orcid_for_person)
      expect(orcid.account_holder).to be_a Lna::Person
      id = orcid.account_holder.primary_org.id
      orcid.account_holder.destroy
      Lna::Organization.find(id).destroy
    end

    it 'can be Lna::Organization' do
      orcid = FactoryGirl.create(:orcid_for_org)
      expect(orcid.account_holder).to be_a Lna::Organization
      expect(orcid.account_holder.accounts).to include orcid
      orcid.account_holder.destroy
    end
  end

  describe 'validations' do
    before :example do
      @orcid = FactoryGirl.create(:orcid_for_person)
    end

    after :example do
      @orcid.reload
      id = @orcid.account_holder.primary_org.id
      @orcid.account_holder.destroy
      Lna::Organization.find(id).destroy
    end
    
    subject { @orcid }
    
    it 'assure account_holder is set' do
      subject.account_holder = nil
      expect(subject.save).to be false
    end

    it 'assure account_holder is a person or organization' do
      subject.account_holder = ActiveFedora::Base.new
      expect(subject.save).to be false
    end
    
    it 'assure title is set' do
      subject.title = nil
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
