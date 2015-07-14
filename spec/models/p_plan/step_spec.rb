require 'rails_helper'

RSpec.describe PPlan::Step, type: :model do

  before :context do
    @step = FactoryGirl.create(:step_with_plan)
  end
  
  after :context do
    PPlan::Plan.find(@step.plan_id).destroy
  end
  
  subject { @step }
  
  it 'has a valid factory' do
    expect(subject).to be_truthy
  end
  
  it { is_expected.to be_instance_of PPlan::Step }
  it { is_expected.to be_kind_of ActiveFedora::Base }
    
  it 'has a title' do
    expect(subject.title).to eql 'Check citation'
  end
    
  it 'has a description' do
    expect(subject.description).to eql 'Ensure citation is correct.'
  end

  it 'has a plan' do
    expect(subject.plan).to be_instance_of PPlan::Plan
  end
  
  context 'when adding next step' do
    before :context do
      @next_step = FactoryGirl.create(:step, plan: @step.plan,
                                      title: 'Next Step')
      @step.next << @next_step
      @step.save
    end

    after :context do
      @step.next.destroy
    end
    
    it 'sets next step' do
      expect(@step.next.size).to eql 1
      expect(@step.next.first).to eq @next_step
    end

    it 'sets previous step in new step' do
      expect(@next_step.previous).to eq @step
    end

  end

  context 'when adding previous step' do
    before :context do
      @previous_step = FactoryGirl.create(:step, plan: @step.plan,
                                          title: 'Previous Step')
      @step.previous = @previous_step
      @step.save
    end

    after :context do
      @step.previous = nil
      @previous_step.destroy
    end
    
    it 'sets previous' do
      expect(@step.previous).to eq @previous_step
    end
      
    it 'sets next in new step' do
      expect(@previous_step.next.first).to eq @step
    end
  end

  context 'when validating' do
    before :example do
      @val_step = FactoryGirl.create(:step_with_plan)
      @val_plan_id = @val_step.plan_id
    end
    
    after :example do
      PPlan::Plan.find(@val_plan_id).destroy
    end

    subject { @val_step }
    
    it 'assures there is a plan' do
      subject.plan = nil
      expect(subject.save).to be false
    end

    it 'assures there is 0 or 1 next step' do
      @step_two = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step Two')
      @step_three = FactoryGirl.create(:step, plan: subject.plan,
                                       title: 'Step Three')
      subject.next << @step_two
      expect(subject.save).to be true
      subject.next << @step_three
      expect(subject.save).to be false
    end

    # A step can't be set to the previous of two different steps.
    it 'assures previous isn\'t set as previous step for different step' do
      @step_one = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step One')
      @step_two = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step Two', previous: @step_one)
      subject.previous = @step_one
      expect(subject.save).to be false
    end
  end
end
