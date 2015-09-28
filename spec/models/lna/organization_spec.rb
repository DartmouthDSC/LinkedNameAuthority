require 'rails_helper'
require 'concerns/lna/organization_core_behavior_spec'

RSpec.describe Lna::Organization, type: :model do  
  it 'has a valid factory' do
    thayer = FactoryGirl.create(:thayer)
    expect(thayer).to be_truthy
    thayer.destroy
  end

  it_behaves_like 'organization_core_behavior', FactoryGirl.create(:thayer)

  describe '.create' do
    before :all do
      @thayer = FactoryGirl.create(:thayer)
    end

    after :context do
      @thayer.destroy
    end

    subject { @thayer }

    it { is_expected.to be_instance_of Lna::Organization }
  end
end
