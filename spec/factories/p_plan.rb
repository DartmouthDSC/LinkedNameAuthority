FactoryGirl.define do
  factory :plan, class: PPlan::Plan do
    title       'Document workflow'
    description 'Assuring a citation is correct.'
    
    # Must have at least one step
    factory :plan_with_step do
      after(:build) do |plan|
        plan.steps << FactoryGirl.create(:step, plan: plan)
      end
    end
  end

  factory :step, class: PPlan::Step do
    title       'Check citation'
    description 'Ensure citation is correct.'
    
    factory :step_with_plan do
      after(:build) do |step|
        step.plan = FactoryGirl.create(:plan, steps: [step])
      end
    end
  end
end
