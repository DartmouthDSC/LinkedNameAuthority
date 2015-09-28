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
      expect(subject.end_date).to match(/\d{4}-\d{2}-\d{2}/)
    end

    it 'sets historic placement'
    
  end

  context '#changed_by'

  context 'validations'
end
