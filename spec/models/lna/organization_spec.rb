require 'rails_helper'

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
      @provost.reload
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

    it 'super organization added has an updated solr document' do
      # check that the super organization has the new sub organization in its solr document.
      provost = Lna::Organization.load_instance_from_solr(@provost.id)
      expect(provost.sub_organizations).to include @thayer
    end
  end

  describe '#serialize' do
    before :context do
      @sub_org = FactoryGirl.create(:thayer, label: 'Thayer Career Services', hr_id: '0020')
      @super_org = FactoryGirl.create(:thayer, label: 'Office of the President', hr_id: '0001')
      @org = FactoryGirl.create(:thayer)
      @org.super_organizations << @super_org
      @org.sub_organizations << @sub_org
      @org.save
    end

    subject { @org.serialize }

    it 'returns hash' do
      expect(subject).to be_instance_of Hash
    end

    it 'hash contains organization attributes' do
      expect(subject[:label]).to eql 'Thayer School of Engineering'
      expect(subject[:hr_id]).to eql '1234'
      expect(subject[:alt_label]).to be_instance_of Array
      expect(subject[:alt_label]).to match_array(['Engineering School', 'Thayer'])
      expect(subject[:begin_date]).to eql '2000-01-01'
    end
    
    it 'hash contains super organization' do
      expect(subject[:super_organizations][0][:label]).to eql 'Office of the President'
    end

    it 'hash contain sub organizations' do
      expect(subject[:sub_organizations][0][:label]).to eql 'Thayer Career Services'
    end
  end
  
  describe '#json_serialization' do
    before :context do
      @org = FactoryGirl.create(:thayer)
    end

    after :context do
      @org.destroy
    end

    subject { @org.json_serialization }
    
    it 'return a string' do
      expect(subject).to be_instance_of String
    end
    
    it 'can be converted to a hash using JSON.parse' do
      expect(JSON.parse(subject)).to be_instance_of Hash
    end
  end

  describe '.convert_to_historic' do
    before :context do
      @change_event = FactoryGirl.create(:hb_change)
      @org = @change_event.resulting_organizations.first
      @jane = FactoryGirl.create(:jane, primary_org: @org)
      @prof = FactoryGirl.create(:thayer_prof, organization: @org)
      @john = FactoryGirl.create(:jane, given_name: 'John', primary_org: @org)
      
      @historic_org = Lna::Organization.convert_to_historic(@org, Date.yesterday)
    end

    subject { @historic_org }

    its(:id)         { is_expected.to eq @org.id }
    its(:label)      { is_expected.to eq 'Thayer School of Engineering' }
    its(:hr_id)      { is_expected.to eq '1234' }
    its(:alt_label)  { is_expected.to match_array ['Engineering School', 'Thayer'] }
    its(:begin_date) { is_expected.to eq Date.parse('2000-01-01') }
    its(:end_date)   { is_expected.to eq Date.yesterday }
    its(:kind)       { is_expected.to eq 'SCH' }
    its(:hinman_box) { is_expected.to eq '1000' }

    its(:people)        { is_expected.to include @jane, @john }
    its(:memberships)   { is_expected.to include @prof }
    its(:resulted_from) { is_expected.to eq @change_event } 

    it 'historic_placement is valid json' do
      expect(JSON.parse(subject.historic_placement)).to be_instance_of Hash
    end
    
    it 'throws error is account are still attached' do
      org = FactoryGirl.create(:orcid_for_org).account_holder
      expect { Lna::Organization.convert_to_historic(org) }.to raise_error ArgumentError 
    end
  end
end
