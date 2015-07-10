FactoryGirl.define do
  factory :name_change, class: Lna::Organization::ChangeEvent do
    at_time                 Time.now
    description             'Organization name change.'

    # Required to have one original_organization and at least one
    # resulting organization.
    after(:build) do |change_event|
      change_event.original_organizations << FactoryGirl.build(:thayer, changed_by: change_event)
      change_event.resulting_organizations << FactoryGirl.build(:thayer, pref_label: 'thayer', resulted_from: change_event)
    end
  end
end
