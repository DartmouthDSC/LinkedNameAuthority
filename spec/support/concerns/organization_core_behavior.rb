RSpec.shared_examples_for 'organization_core_behavior' do |factory|

  before :context do
    @org = FactoryGirl.create(factory)
  end
  
  after :context do
    @org.reload
    @org.people.destroy_all
    @org.destroy
  end

  subject { @org }

  describe '.create' do
    it 'is a ActiveFedora::Base' do
      expect(subject).to be_an ActiveFedora::Base
    end
    
    it 'sets label' do
      expect(subject.label).to eql 'Thayer School of Engineering'
    end
  
    it 'sets alt_label' do
      expect(subject.alt_label).to match_array(['Engineering School', 'Thayer'])
    end
    
    it 'sets code' do 
      expect(subject.code).to start_with 'THAY'
    end
    
    it 'sets begin_date' do
      expect(subject.begin_date).to be_an_instance_of Date
    end
  end

  describe '#people' do
    before :context do 
      @org.people << FactoryGirl.create(:jane, primary_org: @org)
      @org.save
    end
    
    it 'can have a person' do
      expect(subject.people.count).to be >= 1
      expect(subject.people.first).to be_an_instance_of Lna::Person
    end

    it 'can have multiple people' do
      subject.people << FactoryGirl.create(:jane, primary_org: subject)
      expect(subject.people.count).to eql 2
    end
  end

  describe '#memberships' do
    before :context do
      @org.memberships << FactoryGirl.create(:thayer_prof, organization: @org)
      @org.save
    end
    
    it 'can have a membership' do
      expect(subject.memberships.count).to be >= 1
      expect(subject.memberships.first).to be_an_instance_of Lna::Membership
    end

    it 'can have multiple memberships' do
      subject.memberships << FactoryGirl.create(:thayer_prof, title: 'Dean of Thayer',
                                            organization: subject)
      expect(subject.memberships.count).to eql 2
    end
  end
  
  describe '#resulted_from' do
    before :context do
      @change_event = FactoryGirl.create(:code_change, resulting_organizations: [@org])
      @org.reload
    end

    after :context do
      @org.resulted_from = nil
      @org.save
      @change_event.original_organizations.first.destroy
      @change_event.destroy
    end
    
    it 'can be the result of a change event' do
      expect(subject.resulted_from).to be_instance_of Lna::Organization::ChangeEvent
    end
  end

  describe 'validations' do
    it 'assures label is set' do
      subject.label = nil
      expect(subject.save).to be false
      subject.reload
    end
    
    it 'assures begin_date is set' do
      subject.begin_date = nil
      expect(subject.save).to be false
      subject.reload
    end
  end
end
