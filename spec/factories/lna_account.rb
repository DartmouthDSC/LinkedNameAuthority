FactoryGirl.define do
  factory :lna_account do |a|
    a.dc_title                      'Orcid'
    a.foaf_online_account           'http://orcid.org/0000-000-0000'
    a.foaf_account_name             '0000-000-0000'
    a.foaf_account_service_homepage 'http://orcid.org'
  end
end
