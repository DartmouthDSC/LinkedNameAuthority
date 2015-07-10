FactoryGirl.define do
  factory :plan, class: PPlan::Plan do
    title       'THE PLAN'
    description 'Example of a Plan'
    
    after(:build) do |plan|
      plan.steps << FactoryGirl.create(:step, plan: plan)
    end
    
  end
end
