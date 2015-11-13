FactoryGirl.define do
  factory :code_change, class: Lna::Organization::ChangeEvent do
    at_time     '2000-01-01'
    description 'Organization code change.'

    after(:build) do |event|
      if event.original_organizations.size == 0
        event.original_organizations << FactoryGirl.create(:old_thayer, changed_by: event)
      end
      
      if event.resulting_organizations.size == 0
        event.resulting_organizations << FactoryGirl.create(:thayer, resulted_from: event)
      end
    end

    after(:create) do |event|
      event.reload
    end
  end
end
