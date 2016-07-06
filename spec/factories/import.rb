FactoryGirl.define do
  factory :people_import, class: Import do
    load         'People from Test'
    success      true
    time_started DateTime.now
    time_ended   DateTime.now + 2.hours

    factory :org_import do
      load 'Organization from Test'
    end
  end
end

