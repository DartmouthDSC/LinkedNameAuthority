FactoryGirl.define do
  factory :orcid, class: Lna::Account do
    title                    'Orcid'
    account_name             'http://orcid.org/0000-000-0000'
    account_service_homepage 'http://orcid.org'

    factory :orcid_for_person do
      association :account_holder, factory: :jane
    end

    factory :orcid_for_org do
      association :account_holder, factory: :thayer
    end
  end
end
