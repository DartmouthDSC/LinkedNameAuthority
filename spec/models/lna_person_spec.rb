require 'rails_helper'

RSpec.describe LnaPerson, type: :model do
  it 'has valid factory' do
    test = FactoryGirl.create(:lna_person)
    expect(test).to be_truthy
    test.destroy
  end

  context 'when LnaPerson created' do
    before :all do 
      @jane = FactoryGirl.create(:lna_person)
      @jane_orcid = FactoryGirl.create(:lna_account)
      @jane_prof = FactoryGirl.create(:lna_appointment)
    end
    
    it 'is a LnaPerson' do
      expect(@jane).to be_instance_of LnaPerson
    end

    it 'is an ActiveFedora record' do
      expect(@jane).to be_kind_of ActiveFedora::Base
    end
    
    it 'has netid' do
      expect(@jane.dc_netid).to eql 'f12345f'
    end

    it 'has id' do
      expect(@jane.id).to be_truthy
    end

    it 'has name' do
      expect(@jane.foaf_name).to eql 'Jane A. Doe'
    end

    it 'has given name' do
      expect(@jane.foaf_given_name).to eql 'Jane'
    end
    
    it 'has family name' do
      expect(@jane.foaf_family_name).to eql ['Doe']
    end

    it 'has title' do
      expect(@jane.foaf_title).to eql 'Dr.'
    end

    it 'has image' do
      expect(@jane.foaf_image).to eql 'http://ld.dartmouth.edu/api/person/F12345F/img'
    end

    it 'has mbox' do
      expect(@jane.foaf_mbox).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end

    it 'has sha1sum' do
      expect(@jane.foaf_mbox_sha1sum).to eql 'kjflakjfldjskflaskjfdsfdfadfsdfdf'
    end

    it 'has homepage' do
      expect(@jane.foaf_homepage).to eql 'http://janeadoe.dartmouth.edu'
    end

    it 'has publications' do
      expect(@jane.foaf_publications).to eql 'http://dac.dartmouth.edu/person/F12345F'
    end

    it 'has workplace homepage' do
      expect(@jane.foaf_workplace_homepage).to eql 'http://engineering.dartmouth.edu'
    end

    it 'has account' do
      @jane_orcid.lna_person = @jane
      expect(@jane_orcid.lna_person).to be_instance_of(LnaPerson)
    end

    it 'has appointment' do
      @jane_prof.lna_person = @jane
      expect(@jane_prof.lna_person).to be_instance_of(LnaPerson)
    end
    
    after :all do
      @jane.destroy
      @jane_orcid.destroy
      @jane_prof.destroy
    end
  end

  context 'when validating' do
    let (:jane) { FactoryGirl.build(:lna_person) }

    it 'assures name is set' do
      jane.foaf_name = nil
      expect(jane.save).to be false
    end

    it 'assures given name is set' do
      jane.foaf_given_name = nil
      expect(jane.save).to be false
    end

    it 'assures title is set' do
      jane.foaf_title = nil
      expect(jane.save).to be false
    end

    it 'assures mbox is set' do
      jane.foaf_mbox = nil
      expect(jane.save).to be false
    end

    it 'assures mbox sha1sum is set' do
      jane.foaf_mbox_sha1sum = nil
      expect(jane.save).to be false
    end
  end
end
