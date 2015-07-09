FactoryGirl.define do
  factory :orcid, class: Lna::Account do
    title                    'Orcid'
    online_account           'http://orcid.org/0000-000-0000'
    account_name             '0000-000-0000'
    account_service_homepage 'http://orcid.org'

    person                   { FactoryGirl.create(:jane) }
  end
end
