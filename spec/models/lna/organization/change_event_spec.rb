require 'rails_helper'

RSpec.describe Lna::Organization::ChangeEvent, type: :model do

  it 'has a valid factory' do
    name_change = FactoryGirl.create(:name_change)
    expect(name_change).to be_truthy
    name_change.destroy
  end

  context 'when Lna::Organization::ChangeEvent created' do
    before :all do
      @name_change = FactoryGirl.create(:name_change)
    end
    
    it 'is a Lna::Organization::ChangeEvent' do
      expect(@name_change).to be_instance_of Lna::Organization::ChangeEvent
    end
    
    it 'is an ActiveFedora record' do
      expect(@name_change).to be_kind_of ActiveFedora::Base
    end

    it 'has a time'
    
    it 'has a description' do
      expect(@name_change.description).to eql 'Organization name change.'
    end

    it 'has one original organization' do
      expect(@name_change.original_organizations.size).to eql 1
    end

    it 'has resulting organizations'
    
    after :all do
      @name_change.destroy
    end
  end

  context 'when validating' do
    it 'assures that there is only one original organization'

    it 'assures there is at least one resulting organization'
  end
end
