FactoryGirl.define do
  factory :code_change, class: Lna::Organization::ChangeEvent do
    at_time     '2000-01-01'
    description 'Organization code change.'

    after(:build) do |event|
      event.original_organizations << FactoryGirl.create(:old_thayer, changed_by: event)
      event.resulting_organizations << FactoryGirl.create(:thayer, resulted_from: event)
    end
  end
end
