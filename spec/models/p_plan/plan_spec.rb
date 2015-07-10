require 'rails_helper'

RSpec.describe PPlan::Plan, type: :model do
  
  it 'has a valid factory' do
    plan = FactoryGirl.create(:plan)
    expect(plan).to be_truthy
    plan.destroy
  end

  context 'when PPlan::Plan created' do
    before :all do
      @plan = FactoryGirl.create(:plan)
    end

    subject { @plan }

    it { is_expected.to be_instance_of PPlan::Plan }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'has title' do
      expect(subject.title).to eql 'THE PLAN'
    end
    
    it 'has description' do
      expect(subject.description).to eql 'Example of a Plan'
    end

    it 'has a step' do
      expect(subject.steps.size).to eql 1
    end

    it 'can have more than one step' do
      step_two = FactoryGirl.create(:step, title: 'Step 2', plan: subject)
      subject.steps << step_two
      expect(subject.steps.size).to eql 2
      expect(subject.steps).to include step_two
    end
    
    after :all do
      @plan.destroy
    end
  end

  context 'when validating' do
    before :each do
      @plan = FactoryGirl.create(:plan)
    end
    
    it 'assures there is at least one step' do
      @plan.steps.destroy_all
      expect(@plan.save).to be false
    end

    after :each do
      @plan.destroy
    end
  end
end
