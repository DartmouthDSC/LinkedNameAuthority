require 'rails_helper'

RSpec.describe Lna::Membership, type: :model do
  it 'has a valid factory' do
    prof = FactoryGirl.create(:thayer_prof)
    expect(prof).to be_truthy
  end

  describe '.create' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
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

    it 'sets source' do
      expect(subject.source).to eql 'Manual'
    end
  end

  describe '#organization' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    subject { @prof }

    it 'is a Lna::Organization' do
      expect(subject.organization).to be_instance_of Lna::Organization
    end

    it 'can be a Lna::Organization::Historic' do
      historic_org = FactoryGirl.create(:old_thayer)
      active_org = subject.organization
      subject.organization = historic_org
      expect(subject.save).to be true
      expect(subject.organization).to be_instance_of Lna::Organization::Historic
      subject.organization = active_org
      subject.save
      historic_org.destroy
    end
    
    it 'contains this as one of its memberships' do
      expect(subject.organization.memberships).to include @prof
    end
  end  

  describe '#person' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof)
    end

    subject { @prof }
    
    it 'is a Lna::Person' do
      expect(subject.person).to be_instance_of Lna::Person
    end

    it 'contains this as one of its memberships' do
      expect(subject.person.memberships).to include @prof
    end
  end

  describe '#end_date=' do
    let!(:prof) { FactoryGirl.create(:thayer_prof, end_date: nil)  }
    let!(:primary_org) { prof.person.primary_org }

    it 'sets end date' do
      prof.update(end_date: Date.today)
      expect(prof.end_date).to eq Date.today
    end
  end
  
  describe '#update_primary_org' do
    let!(:prof) { FactoryGirl.create(:thayer_prof, end_date: nil)  }
    let!(:primary_org) { prof.person.primary_org }
    
    context 'updates the person\'s primary organization' do
      it 'when there are other active memberships with active organizations' do
        new_mem = FactoryGirl.create(:thayer_prof, person: prof.person)
        new_primary_org = new_mem.organization
        prof.person.memberships << new_mem
        prof.person.save
        prof.end_date = Date.today
        prof.save
        expect(prof.person.primary_org).to eq new_primary_org
      end
    end
    
    context 'does not update the person\'s primary organization' do
      it 'when there are no other membership' do
        prof.end_date = Date.today
        prof.save
        expect(prof.person.primary_org).to eq primary_org
      end
      
      it 'when there are no other active memberships' do
        prof.person.memberships << FactoryGirl.create(:thayer_prof, person: prof.person,
                                                      end_date: Date.today)
        prof.person.save
        prof.person.reload
        prof.end_date = Date.today
        prof.save
        expect(prof.person.primary_org).to eq primary_org
      end

      it 'when there are active memberships with historical organizations' do
        old_thayer = FactoryGirl.create(:old_thayer)
        prof.person.memberships << FactoryGirl.create(:thayer_prof, person: prof.person,
                                                      organization: old_thayer)
        prof.person.save
        prof.person.reload
        prof.end_date = Date.today
        prof.save
        expect(prof.person.primary_org).to eq primary_org
      end
    end
  end

  describe '#end_date_set?' do
    it 'when end_date set return true' do
      prof = FactoryGirl.create(:thayer_prof)
      expect(prof.end_date_set?).to be true
    end

    it 'when end_date not set return false' do
      prof = FactoryGirl.create(:thayer_prof, end_date: nil)
      expect(prof.end_date_set?).to be false
    end
  end
  
  describe '#ended?' do
    it 'returns true if membership ended on or before today' do
      prof = FactoryGirl.create(:thayer_prof, end_date: Date.today)
      expect(prof.ended?).to be true
    end

    it 'returns false is membership still active' do
      prof = FactoryGirl.create(:thayer_prof)
      expect(prof.ended?).to be false
    end
  end

  describe '#active?' do
    it 'returns true if membership active on today' do
      prof = FactoryGirl.create(:thayer_prof)
      expect(prof.active?).to be true
    end

    it 'returns false if membership not active today' do
      prof = FactoryGirl.create(:thayer_prof, end_date: Date.today)
      expect(prof.active?).to be false
    end
  end
  
  describe '#active_on?' do
    before :context do
      @prof = FactoryGirl.create(:thayer_prof, begin_date: Date.yesterday)
    end

    subject { @prof }
    
    it 'returns true if date is the same as begin_date' do
      expect(@prof.active_on? Date.yesterday).to be true
    end

    it 'returns true if the date is between begin_date and end_date' do
      expect(@prof.active_on? Date.today).to be true
    end

    it 'return false if date is before begin_date' do
      expect(@prof.active_on? Date.yesterday - 1).to be false
    end

    it 'return false if date is on end_date' do
      expect(@prof.active_on? Date.tomorrow).to be false
    end

    it 'returns false if date is after end_date' do
      expect(@prof.active_on? Date.tomorrow + 1).to be false
    end
  end
  
  describe 'validations' do
    let(:prof) { FactoryGirl.create(:thayer_prof) }
    
    subject { prof }
    
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

    it 'assure end_date is after begin_date' do
      subject.end_date = subject.begin_date - 3
      expect(subject.save).to be false
    end
    
    it 'assure begin_date is before end_date' do
      subject.begin_date = Date.tomorrow
      subject.end_date = Date.today
      expect(subject.save).to be false
    end

    it 'assures organization is a Lna::Organization or Lna::Organization::Historic' do
      subject.organization = ActiveFedora::Base.new
      expect(subject.save).to be false
    end
  end
end
