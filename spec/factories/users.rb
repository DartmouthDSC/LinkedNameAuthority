FactoryGirl.define do
  factory :user do
    name      'Jane A. Doe'
    netid     'f12345f'
    uid       'f12345f@dartmouth.edu'
    provider  :cas
    realm     'dartmouth.edu'
    affil     'DART'
  end
end
