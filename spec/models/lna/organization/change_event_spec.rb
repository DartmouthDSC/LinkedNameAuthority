require 'rails_helper'

RSpec.describe Lna::Organization::ChangeEvent, type: :model do

  it 'has a valid factory' do
    name_change = FactoryGirl.create(:thayer_name_change)
    expect(name_change).to be_truthy
    name_change.destroy
  end

  context 'when Lna::Organization::ChangeEvent created' do
    before :all do
      @name_change = FactoryGirl.create(:thayer_name_change)
    end
    
    it 'is a Lna::Organization::ChangeEvent' do
      expect(@name_change).to be_instance_of Lna::Organization::ChangeEvent
    end
    
    it 'is an ActiveFedora record' do
      expect(@name_change).to be_kind_of ActiveFedora::Base
    end
    
    it 'has a description' do
      expect(@name_change.description).to eql 'Organization name change.'
    end

    after :all do
      @name_change.destroy
    end
    
  end

  context 'when validating'

end
