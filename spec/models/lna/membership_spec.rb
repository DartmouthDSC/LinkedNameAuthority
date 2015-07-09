require 'rails_helper'

RSpec.describe Lna::Membership, :type => :model do
  
  it 'has a valid factory' do
    prof = FactoryGirl.create(:thayer_prof)
    expect(prof).to be_truthy
    prof.destroy
  end

  context 'when Lna::Membership created' do
    before :all do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    it 'is a LnaAppointment' do
      expect(@prof).to be_instance_of Lna::Membership
    end

    it 'is an ActiveFedora record' do
      expect(@prof).to be_kind_of ActiveFedora::Base
    end
    
    it 'has title' do
      expect(@prof.title).to eql 'Professor of Engineering'
    end
    
    it 'has email' do
      expect(@prof.email).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end
    
    it 'has organization'

    
    it 'has street address' do
      expect(@prof.street_address).to eql '14 Engineering Dr.'
    end
    
    it 'has pobox' do
      expect(@prof.pobox).to eql 'HB 0000'
    end
    
    it 'has locality' do
      expect(@prof.locality).to eql 'Hanover, NH'
    end
    
    it 'has postal code' do
      expect(@prof.postal_code).to eql '03755'
    end
    
    it 'has country code' do
      expect(@prof.country_name).to eql 'United States'
    end

    after :all do
      @prof.destroy
    end
  end
  
  
  context 'when validating' do
    before :all do
      @prof = FactoryGirl.build(:thayer_prof)
    end
    
    it 'assures title is set' do
      @prof.title = nil
      expect(@prof.save).to be false
    end

    it 'assures organization is set' do
      @prof.organization = nil
      expect(@prof.save).to be false
    end
  end

end
