require 'rails_helper'

RSpec.describe :LnaAppointment, :type => :model do

  ## Check owltime
  
  it 'has a valid factory' do
    prof = FactoryGirl.create(:lna_appointment)
    expect(prof).to be_truthy
    prof.destroy
  end

  context 'when LnaAppointment created' do
    before :all do
      @prof = FactoryGirl.create(:lna_appointment)
    end

    it 'is a LnaAppointment' do
      expect(@prof).to be_instance_of LnaAppointment
    end

    it 'is an ActiveFedora record' do
      expect(@prof).to be_kind_of ActiveFedora::Base
    end
    
    it 'has title' do
      expect(@prof.vcard_title).to eql 'Professor of Engineering'
    end
    
    it 'has email' do
      expect(@prof.vcard_email).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end
    
    it 'has org' do
      expect(@prof.vcard_org).to eql 'http://ld.dartmouth.edu/api/org/thayer'
    end
    
    it 'has street address' do
      expect(@prof.vcard_street_address).to eql '14 Engineering Dr.'
    end
    
    it 'has pobox' do
      expect(@prof.vcard_pobox).to eql 'HB 0000'
    end
    
    it 'has locality' do
      expect(@prof.vcard_locality).to eql 'Hanover, NH'
    end
    
    it 'has postal code' do
      expect(@prof.vcard_postal_code).to eql '03755'
    end
    
    it 'has country code' do
      expect(@prof.vcard_country_name).to eql 'United States'
    end
    
    it 'has has beginning' do
      expect(@prof.time_has_beginning).to eql 'July 1, 2014'
    end
    
    it 'has has end' do
      expect(@prof.time_has_end).to eql 'June 30, 2015'
    end

    after :all do
      @prof.destroy
    end
  end
  
  
  context 'when validating' do
    before :all do
      @prof = FactoryGirl.build(:lna_appointment)
    end
    
    it 'assures title is set' do
      @prof.vcard_title = nil
      expect(@prof.save).to be false
    end

    it 'assures org is set' do
      @prof.vcard_org = nil
      expect(@prof.save).to be false
    end

    it 'assures has beginning is set' do
      @prof.time_has_beginning = nil
      expect(@prof.save).to be false
    end
  end

end
