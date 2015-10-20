require 'rails_helper'
require 'concerns/lna/organization_core_behavior_spec'

RSpec.describe Lna::Organization, type: :model do  
  it 'has a valid factory' do
    thayer = FactoryGirl.create(:thayer)
    expect(thayer).to be_truthy
    thayer.destroy
  end

  it_behaves_like 'organization_core_behavior', :thayer

  describe '.create' do
    before :all do
      @thayer = FactoryGirl.create(:thayer)
    end

    after :context do
      @thayer.destroy
    end

    subject { @thayer }

    it { is_expected.to be_instance_of Lna::Organization }
  end

  describe '#account' do
    before :context do
      @thayer = FactoryGirl.create(:thayer)
      FactoryGirl.create(:orcid, account_holder: @thayer)
    end

    after :context do
      @thayer.destroy
    end

    subject { @thayer }
    
    it 'can have an account' do
      expect(subject.accounts.count).to eql 1
      expect(subject.accounts.first).to be_instance_of Lna::Account
    end
    
    it 'can have multiple accounts' do
      FactoryGirl.create(:orcid, account_holder: subject)
      subject.reload
      expect(subject.accounts.count).to eql 2
    end
  end

  describe '#sub_organizations' do
    before :context do
      @thayer = FactoryGirl.create(:thayer)
      @career_services = FactoryGirl.create(:thayer, label: 'Thayer Career Services')
      @thayer.sub_organizations << @career_services
      @thayer.save
    end

    after :context do
      @thayer.sub_organizations.destroy_all
      @thayer.destroy
    end

    subject { @thayer }
    
    it 'can have a sub organization' do
      expect(subject.sub_organizations.size).to eql 1
      expect(@career_services.super_organizations.first).to eql subject
      expect(subject.sub_organizations.first).to be_instance_of Lna::Organization
    end
    
    it 'can have multiple sub organizations' do
      deans_office = FactoryGirl.create(:thayer, label: 'Office of the Dean')
      subject.sub_organizations << deans_office
      subject.save
      expect(subject.sub_organizations.size).to eql 2
      expect(subject.sub_organizations).to include deans_office
    end
  end

  describe '#super_organizations' do
    before :context do
      @provost = FactoryGirl.create(:thayer, label: 'Office of the Provost')
      @thayer = FactoryGirl.create(:thayer)
      @thayer.super_organizations << @provost
      @thayer.save
    end

    after :context do
      @thayer.reload
      @thayer.super_organizations.to_a.each { |a| a.destroy }
      @thayer.destroy
    end

    subject { @thayer }
    
    it 'can have a super organization' do
      expect(subject.super_organizations.size).to eql 1
      expect(@provost.sub_organizations.first).to eq subject
      expect(subject.super_organizations.first).to be_instance_of Lna::Organization
    end

    it 'can have multiple super organization' do
      pres = FactoryGirl.create(:thayer, label: 'Office of the President')
      subject.super_organizations << pres
      subject.save
      expect(subject.super_organizations.size).to eql 2
      expect(subject.super_organizations).to include pres
    end
  end
end
