FactoryGirl.define do
  factory :orcid, class: Lna::Account do
    title                    'ORCID'
    account_name             'http://orcid.org/0000-000-0000'
    account_service_homepage 'http://orcid.org'

    factory :orcid_for_person do
      association :account_holder, factory: :jane
    end

    factory :orcid_for_org do
      association :account_holder, factory: :thayer
    end
  end

  factory :netid, class: Lna::Account do
    title                    'Dartmouth'
    account_name             'd00000a'
    account_service_homepage 'dartdm.dartmouth.edu'
    
    association :account_holder, factory: :jane
  end
end
