require 'rails_helper'

RSpec.describe Lna::Membership, type: :model do
  it 'has a valid factory' do
    prof = FactoryGirl.create(:thayer_prof)
    expect(prof).to be_truthy
    prof.destroy
  end

  describe '.create' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    subject { @prof }
    
    it { is_expected.to be_instance_of Lna::Membership }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'has title' do
      expect(@prof.title).to eql 'Professor of Engineering'
    end
    
    it 'has email' do
      expect(@prof.email).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end
    
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

  describe 'associations' do
    before (:context) { @prof = FactoryGirl.create(:thayer_prof) }
    after  (:context) { @prof.destroy }

    subject { @prof }

    it 'has a organization' do
      expect(subject.organization).to be_a Lna::Organization
    end

    # check that the organization has a pointer to this membership?
    # check that the person is pointing to this as one of its membership?

    it 'has a person' do
      expect(subject.person).to be_a Lna::Person
    end
  end  
  
  describe 'validations' do
    before :example do
      @prof = FactoryGirl.build(:thayer_prof)
    end

    subject { @prof }
    
    it 'assures title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end

    it 'assures member during is set' do
      subject.member_during = nil
      expect(subject.save).to be false
    end

    it 'assures organization is set' do
      subject.organization = nil
      expect(subject.save).to be false
    end

    it 'assures person is set' do
      subject.organization = nil
      expect(subject.save).to be false
    end
  end

end
