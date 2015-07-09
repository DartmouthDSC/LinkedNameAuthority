FactoryGirl.define do
  factory :jane, class: Lna::Person do
    full_name          'Jane A. Doe'
    given_name         'Jane'
    family_name        ['Doe']
    title              'Dr.'
    image              'http://ld.dartmouth.edu/api/person/F12345F/img'
    mbox               'mailto:jane.a.doe@dartmouth.edu'
    mbox_sha1sum       'kjflakjfldjskflaskjfdsfdfadfsdfdf'
    homepage           'http://janeadoe.dartmouth.edu'
    primary_org        { FactoryGirl.create(:thayer) }
  end
end
