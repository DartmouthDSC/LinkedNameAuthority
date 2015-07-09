FactoryGirl.define do
  factory :thayer_name_change, class: Lna::Organization::ChangeEvent do |o|
    o.at_time     Time.now
    o.description 'Organization name change.'
  end
end
