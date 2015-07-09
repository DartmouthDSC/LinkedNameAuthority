require 'rails_helper'

RSpec.describe Lna::Person, type: :model do
  it 'has valid factory' do
    test = FactoryGirl.create(:jane)
    expect(test).to be_truthy
    test.destroy
  end

  context 'when Lna::Person created' do
    before :all do 
      @jane = FactoryGirl.create(:jane)
      @jane_orcid = FactoryGirl.create(:orcid)
      @jane_prof = FactoryGirl.create(:thayer_prof)
    end
    
    it 'is a Lna::Person' do
      expect(@jane).to be_instance_of Lna::Person
    end

    it 'is an ActiveFedora record' do
      expect(@jane).to be_kind_of ActiveFedora::Base
    end

    it 'has id' do
      expect(@jane.id).to be_truthy
    end

    it 'has full name' do
      expect(@jane.full_name).to eql 'Jane A. Doe'
    end

    it 'has given name' do
      expect(@jane.given_name).to eql 'Jane'
    end
    
    it 'has family name' do
      expect(@jane.family_name).to eql ['Doe']
    end

    it 'has title' do
      expect(@jane.title).to eql 'Dr.'
    end

    it 'has image' do
      expect(@jane.image).to eql 'http://ld.dartmouth.edu/api/person/F12345F/img'
    end

    it 'has mbox' do
      expect(@jane.mbox).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end

    it 'has sha1sum' do
      expect(@jane.mbox_sha1sum).to eql 'kjflakjfldjskflaskjfdsfdfadfsdfdf'
    end

    it 'has homepage' do
      expect(@jane.homepage).to eql 'http://janeadoe.dartmouth.edu'
    end

    it 'has publications'

    it 'has account' do
      @jane_orcid.person = @jane
      expect(@jane_orcid.person).to be_instance_of(Lna::Person)
    end

    it 'has appointment' do
      @jane_prof.person = @jane
      expect(@jane_prof.person).to be_instance_of(Lna::Person)
    end
    
    after :all do
      @jane.destroy
      @jane_orcid.destroy
      @jane_prof.destroy
    end
  end

  context 'when validating' do
    let (:jane) { FactoryGirl.build(:jane) }

    it 'assures full name is set' do
      jane.full_name = nil
      expect(jane.save).to be false
    end

    it 'assures given name is set' do
      jane.given_name = nil
      expect(jane.save).to be false
    end

    it 'assures title is set' do
      jane.title = nil
      expect(jane.save).to be false
    end

    it 'assures mbox is set' do
      jane.mbox = nil
      expect(jane.save).to be false
    end

    it 'assures mbox sha1sum is set' do
      jane.mbox_sha1sum = nil
      expect(jane.save).to be false
    end
  end
end
