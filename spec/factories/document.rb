FactoryGirl.define do
  factory :document, class: Lna::Collection::Document do
    title                    'The best paper ever'

    factory :document_with_person do
      association :person, factory: :jane
    end
  end
end
