require 'rails_helper'

RSpec.describe Lna::Person, type: :model do
  it 'has valid factory' do
    jane = FactoryGirl.create(:jane)
    expect(jane).to be_truthy
    id = jane.primary_org.id
    jane.destroy
    Lna::Organization.find(id).destroy
  end

  describe '.create' do
    before :context do 
      @jane = FactoryGirl.create(:jane)
    end
    
    after :context do
      id = @jane.primary_org.id
      @jane.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @jane }
    
    it { is_expected.to be_instance_of Lna::Person }
    it { is_expected.to be_a ActiveFedora::Base }

    it 'creates id' do
      expect(subject.id).to be_truthy
    end
    
    it 'sets full name' do
      expect(subject.full_name).to eql 'Jane A. Doe'
    end

    it 'sets given name' do
      expect(subject.given_name).to eql 'Jane'
    end
    
    it 'sets family name' do
      expect(subject.family_name).to eql 'Doe'
    end

    it 'sets title' do
      expect(subject.title).to eql 'Dr.'
    end

    it 'sets image' do
      expect(subject.image).to eql 'http://ld.dartmouth.edu/api/person/F12345F/img'
    end

    it 'sets mbox' do
      expect(subject.mbox).to eql 'mailto:jane.a.doe@dartmouth.edu'
    end

    it 'sets sha1sum' do
      expect(subject.mbox_sha1sum).to eql 'kjflakjfldjskflaskjfdsfdfadfsdfdf'
    end

    it 'sets homepage' do
      expect(subject.homepage).to eql ['http://janeadoe.dartmouth.edu']
    end

    it 'creates a collection object' do
      expect(subject.collections.count).to eql 1
      expect(subject.collections.first).to be_instance_of Lna::Collection
      expect(subject.collections.first.person.id).to eql subject.id
    end
  end

  describe '#primary_org' do
    before :context do
      @jane = FactoryGirl.create(:jane)
    end

    after :context do
      id = @jane.primary_org.id
      @jane.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @jane }
    
    it 'is an Lna::Organization' do
      expect(subject.primary_org).to be_instance_of Lna::Organization
    end

    it 'can be a Lna::Organization::Historic' do
      active_id = subject.primary_org.id
      subject.primary_org = FactoryGirl.create(:old_thayer)
      subject.save
      expect(subject.primary_org).to be_instance_of Lna::Organization::Historic
      historic_id = subject.primary_org.id
      subject.primary_org = Lna::Organization.find(active_id)
      subject.save
      Lna::Organization::Historic.find(historic_id).destroy
    end
    
    it 'sets person in primary org' do
      expect(subject.primary_org.people).to include @jane
    end
  end
  
  describe '#accounts' do
    before :context do
      @jane = FactoryGirl.create(:jane)
      @orcid = FactoryGirl.create(:orcid_for_person, account_holder: @jane)
    end
    
    after :context do
      id = @jane.primary_org.id
      @jane.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @jane }
    
    it 'is a Lna::Account' do
      expect(subject.accounts.first).to be_instance_of Lna::Account
      expect(subject.accounts).to match_array [@orcid]
    end

    it 'sets account_holder in account' do
      expect(@orcid.account_holder).to eq subject
    end

    it 'can have more than one account' do
      orcid_two = FactoryGirl.create(:orcid_for_person, account_holder: @jane)
      subject.accounts << orcid_two
      subject.save
      expect(subject.accounts).to match_array [@orcid, orcid_two]
      orcid_two.destroy
    end
  end

  describe '#membership' do
    before :context do
      @jane = FactoryGirl.create(:jane)
      @prof = FactoryGirl.create(:thayer_prof, organization: @jane.primary_org,
                                 person: @jane)
    end

    after :context do
      @prof.person.destroy
      @prof.organization.destroy
    end
    
    it 'is a Lna::Membership' do
      expect(@jane.memberships.first).to be_instance_of Lna::Membership
      expect(@jane.memberships).to match_array [@prof]
    end

    it 'sets person in membership' do
      expect(@prof.person).to eq @jane
    end

    it 'can have more than one membership' do
      dean = FactoryGirl.create(:thayer_prof, title: 'Dean of Thayer', person: @jane,
                                organization: @jane.primary_org)
      @jane.reload
      expect(@jane.memberships).to match [@prof, dean]
    end
  end

  describe 'validations' do
    before :example do
      @jane = FactoryGirl.create(:jane)
    end

    after :example do
      @jane.reload
      id = @jane.primary_org.id
      @jane.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @jane }

    it 'assure full name is set' do
      subject.full_name = nil
      expect(subject.save).to be false
    end

    it 'assure given name is set' do
      subject.given_name = nil
      expect(subject.save).to be false
    end

    it 'assure family name is set' do
      subject.family_name = nil
      expect(subject.save).to be false
    end

    it 'assure primary organization is set' do
      subject.primary_org = nil
      expect(subject.save).to be false
    end

    it 'assures there is no more than one collection' do
      subject.collections << Lna::Collection.create(person: subject)
      expect(subject.save).to be false
    end

    it 'assures there is at least one collection' do
      subject.collections = []
      expect(subject.save).to be false
    end

    it 'assures primary_org is an Lna::Organization or Lna::Organization::Historic' do
      subject.primary_org = ActiveFedora::Base.new
      expect(subject.save).to be false
    end
  end
end
