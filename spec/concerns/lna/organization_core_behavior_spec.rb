require 'spec_helper'

shared_examples_for 'organization_core_behavior' do |org|
  after :context do
    org.reload
    org.people.destroy_all
    org.destroy
  end

  describe '.create' do
    it 'is a ActiveFedora::Base' do
      expect(org).to be_an ActiveFedora::Base
    end
    
    it 'sets label' do
      expect(org.label).to eql 'Thayer School of Engineering'
    end
  
    it 'sets alt_label' do
      expect(org.alt_label).to match_array(['Engineering School', 'Thayer'])
    end
    
    it 'sets code' do 
      expect(org.code).to start_with 'THAY'
    end
    
    it 'sets begin_date' do
      expect(org.begin_date).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end

  describe '#people' do
    before :context do 
      org.people << FactoryGirl.create(:jane, primary_org: org)
      org.save
    end
    
    it 'can have a person' do
      expect(org.people.count).to be >= 1
      expect(org.people.first).to be_an_instance_of Lna::Person
    end
  end

  describe '#memberships' do
    before :context do
      org.memberships << FactoryGirl.create(:thayer_prof, organization: org)
      org.save
    end
    
    it 'can have a membership' do
      expect(org.memberships.count).to be >= 1
      expect(org.memberships.first).to be_an_instance_of Lna::Membership
    end
  end
  
  describe '#resulted_from' do
    before :context do
      org.resulted_from = FactoryGirl.create(:code_change)
    end
    
    it 'can be the result of a change event' do
      expect(org.resulted_from).to be_instance_of Lna::Organization::ChangeEvent
    end
  end

  describe 'validations' do
    it 'assures label is set' do
      org.label = nil
      expect(org.save).to be false
      org.reload
    end
    
    it 'assures begin_date is set' do
      org.begin_date = nil
      expect(org.save).to be false
      org.reload
    end
  end
end
