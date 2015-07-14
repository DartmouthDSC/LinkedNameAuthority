require 'rails_helper'

RSpec.describe Lna::Person, type: :model do

  before :context do 
    @jane = FactoryGirl.create(:jane)
  end

  after :context do
    @jane.destroy
  end

  subject { @jane }

  it 'has valid factory' do
    expect(subject).to be_truthy
  end
    
  it { is_expected.to be_instance_of Lna::Person }
  it { is_expected.to be_a ActiveFedora::Base }

  it 'has id' do
    expect(subject.id).to be_truthy
  end

  it 'has full name' do
    expect(subject.full_name).to eql 'Jane A. Doe'
  end

  it 'has given name' do
    expect(subject.given_name).to eql 'Jane'
  end
    
  it 'has family name' do
    expect(subject.family_name).to eql 'Doe'
  end

  it 'has title' do
    expect(subject.title).to eql 'Dr.'
  end

  it 'has image' do
    expect(subject.image).to eql 'http://ld.dartmouth.edu/api/person/F12345F/img'
  end

  it 'has mbox' do
    expect(subject.mbox).to eql 'mailto:jane.a.doe@dartmouth.edu'
  end

  it 'has sha1sum' do
    expect(subject.mbox_sha1sum).to eql 'kjflakjfldjskflaskjfdsfdfadfsdfdf'
  end

  it 'has homepage' do
    expect(subject.homepage).to eql ['http://janeadoe.dartmouth.edu']
  end

  it 'has primary organization' do
    expect(subject.primary_org).to be_instance_of Lna::Organization
  end
  
  it 'can have publications'

  it 'can have account' do
    orcid = FactoryGirl.create(:orcid)
    subject.accounts << orcid
    subject.save
    expect(subject.accounts.first).to be_instance_of Lna::Account
    expect(subject.accounts).to match_array [orcid]
  end

  it 'can have membership' do
    prof = FactoryGirl.create(:thayer_prof)
    subject.memberships << prof
    subject.save
    expect(subject.memberships).to match_array [prof]
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

    it 'assures family name is set' do
      jane.family_name = nil
      expect(jane.save).to be false
    end

    it 'assures primary organization is set' do
      jane.primary_org = nil
      expect(jane.save).to be false
    end
  end
end
