FactoryGirl.define do
  factory :code_change, class: Lna::Organization::ChangeEvent do
    at_time     '2000-01-01'
    description 'Organization code change.'

    association :original_organizations, factory: :old_thayer
    association :resulting_organizations, factory: :thayer
  end
end
