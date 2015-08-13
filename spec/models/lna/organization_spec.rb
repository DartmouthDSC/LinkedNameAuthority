require 'rails_helper'

RSpec.describe Lna::Organization, type: :model do

  it 'has a valid factory' do
    thayer = FactoryGirl.create(:thayer)
    expect(thayer).to be_truthy
    thayer.destroy
  end

  context 'when Lna::Organization created' do
    before :all do
      @thayer = FactoryGirl.create(:thayer)
    end

    after :context do
      @thayer.destroy
    end
    
    it 'is a Lna::Organization' do
      expect(@thayer).to be_instance_of Lna::Organization
    end
    
    it 'is an ActiveFedora record' do
      expect(@thayer).to be_kind_of ActiveFedora::Base
    end
    
    it 'has a label' do
      expect(@thayer.label).to eql 'Thayer School of Engineering'
    end

    it 'has alternative labels' do
      expect(@thayer.alt_label).to match_array(['Engineering School', 'Thayer'])
    end
  end

  context 'when validating'

end
