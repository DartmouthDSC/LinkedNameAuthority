require 'rails_helper'

RSpec.describe Lna::Membership, type: :model do
  it 'has a valid factory' do
    prof = FactoryGirl.create(:thayer_prof)
    expect(prof).to be_truthy
    prof.person.destroy
    prof.organization.destroy
  end

  describe '.create' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    after :context do
      @prof.person.destroy
      @prof.organization.destroy
    end
    
    subject { @prof }
    
    it { is_expected.to be_instance_of Lna::Membership }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'sets title' do
      expect(subject.title).to eql 'Professor of Engineering'
    end
    
    it 'sets email' do
      expect(subject.email).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end
    
    it 'sets street address' do
      expect(subject.street_address).to eql '14 Engineering Dr.'
    end
    
    it 'sets pobox' do
      expect(subject.pobox).to eql 'HB 0000'
    end
    
    it 'sets locality' do
      expect(subject.locality).to eql 'Hanover, NH'
    end
    
    it 'sets postal code' do
      expect(subject.postal_code).to eql '03755'
    end
    
    it 'sets country code' do
      expect(subject.country_name).to eql 'United States'
    end

    it 'sets begin date' do
      expect(subject.begin_date).to be_instance_of Date
      expect(subject.begin_date.to_s).to eql Date.today.to_s
    end
    
    it 'sets end date' do
      expect(subject.end_date).to be_instance_of Date
      expect(subject.end_date.to_s).to eql Date.tomorrow.to_s
    end
  end

  describe '#organization' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
      @prof.organization.save
    end
    
    after :context do
      @prof.person.destroy
      @prof.organization.destroy
    end

    subject { @prof }

    it 'is a Lna::Organization' do
      expect(subject.organization).to be_instance_of Lna::Organization
    end

    it 'can be a Lna::Organization::Historic'
    
    it 'contains this as one of its memberships' do
      expect(subject.organization.memberships).to include @prof
    end
  end  

  describe '#person' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    after :context do
      @prof.person.destroy
      @prof.organization.destroy
    end

    subject { @prof }
    
    it 'is a Lna::Person' do
      expect(subject.person).to be_instance_of Lna::Person
    end

    it 'contains this as one of its memberships' do
      expect(subject.person.memberships).to include @prof
    end
  end
  
  describe 'validations' do
    before :example do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    after :example do
      @prof.reload
      @prof.person.destroy
      @prof.organization.destroy
    end

    subject { @prof }
    
    it 'assure title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end

    it 'assure organization is set' do
      subject.organization = nil
      expect(subject.save).to be false
    end

    it 'assure person is set' do
      subject.person = nil
      expect(subject.save).to be false
    end

    it 'assure begin_date is set' do
      subject.begin_date = nil
      expect(subject.save).to be false
    end
  end
end
