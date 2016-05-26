require 'rails_helper'

RSpec.describe Lna::Organization::Historic, type: :model do
  it 'has a valid factory' do
    old_thayer = FactoryGirl.create(:old_thayer)
    expect(old_thayer).to be_truthy
    old_thayer.destroy
  end

  it_behaves_like 'organization_core_behavior', :old_thayer

  context '.create' do
    before :context do
      @old_thayer = FactoryGirl.create(:old_thayer)
    end
    
    after :context do
      @old_thayer.destroy
    end
    
    subject { @old_thayer }

    it { is_expected.to be_instance_of Lna::Organization::Historic }

    it 'sets end date' do
      expect(subject.end_date).to be_instance_of Date
      expect(subject.end_date.to_s).to eql '2000-01-01'
    end

    it 'sets historic placement' do
      expect(subject.historic_placement).to eql '{}'
    end
  end

  context '#changed_by' do
    before :context do
      @old_thayer = FactoryGirl.create(:old_thayer)
      @new_thayer = FactoryGirl.create(:thayer)
      @change_event = FactoryGirl.create(:hb_change, resulting_organizations: [@new_thayer],
                                         original_organizations: [@old_thayer])
    end

    after :context do
      @old_thayer.destroy
      @new_thayer.destroy
      @change_event.destroy
    end

    subject { @old_thayer }
    
    it 'can have one changed_by event' do
      expect(subject.changed_by).to be_instance_of Lna::Organization::ChangeEvent
      expect(subject.changed_by).to be @change_event
    end
  end

  context 'validations' do    
    subject { FactoryGirl.create(:old_thayer) }
    
    it 'assures end date is set' do
      subject.end_date = nil
      expect(subject.save).to be false
    end

    it 'assures end date is after begin date' do
      subject.end_date = Date.parse('1980-01-01')
      expect(subject.save).to be false
    end
  end
end
