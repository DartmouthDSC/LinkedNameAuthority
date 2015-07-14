require 'rails_helper'

RSpec.describe PPlan::Plan, type: :model do
  
  it 'has a valid factory' do
    plan = FactoryGirl.create(:plan_with_step)
    expect(plan).to be_truthy
    plan.destroy
  end

  context 'when creating' do 
    before :context do
      @plan = FactoryGirl.create(:plan_with_step)
    end

    subject { @plan }

    it { is_expected.to be_instance_of PPlan::Plan }
    it { is_expected.to be_an ActiveFedora::Base }
    
    it 'has title' do
      expect(subject.title).to eql 'Document workflow'
    end

    it 'has description' do
      expect(subject.description).to eql 'Assuring a citation is correct.'
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
    
    after :context do
      @plan.destroy
    end
  end
  
  context 'when validating' do
    before :example do
      @val_plan = FactoryGirl.create(:plan_with_step)
    end

    subject { @val_plan }

    it 'assures there is a title' do
      subject.title = nil
      expect(subject.save).to be false
    end
    
    it 'assures there is a description' do
      subject.description = nil
      expect(subject.save).to be false
    end
    
    it 'assures there is at least one step' do
      subject.steps.destroy_all
      expect(subject.save).to be false
    end

    after :example do
      @val_plan.destroy
    end
  end
end
