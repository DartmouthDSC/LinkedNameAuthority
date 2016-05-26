FactoryGirl.define do
  factory :jane, class: Lna::Person do
    full_name     'Jane A. Doe'
    given_name    'Jane'
    family_name   'Doe'
    title         'Dr.'
    image         'http://ld.dartmouth.edu/api/person/F12345F/img'
    mbox          'jane.a.doe@dartmouth.edu'
    homepage      ['http://janeadoe.dartmouth.edu']
    association   :primary_org, factory: :thayer
  end
end
