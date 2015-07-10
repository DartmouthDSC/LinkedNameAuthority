FactoryGirl.define do
  factory :step, class: PPlan::Step do
    title       'Step 1'
    description 'Just getting started...'

    # needs to have a :plan
    association :plan, factory: :plan
  end
end
