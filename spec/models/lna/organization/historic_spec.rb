require 'rails_helper'
require 'concerns/lna/organization_core_behavior_spec'

RSpec.describe Lna::Organization::Historic, type: :model do
  it 'has a valid factory' do
    old_thayer = FactoryGirl.create(:old_thayer)
    expect(old_thayer).to be_truthy
    old_thayer.destroy
  end

  it_behaves_like 'organization_core_behavior', FactoryGirl.create(:old_thayer)

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

    it 'sets historic placement'
    
  end

  context '#changed_by'

  context 'validations' do
    before :example do
      @old_thayer = FactoryGirl.create(:old_thayer)
    end

    after :example do
      @old_thayer.destroy
    end
    
    subject { @old_thayer }
    
    it 'assures end date is set' do
      subject.end_date = nil
      expect(subject.save).to be false
    end
  end
end
