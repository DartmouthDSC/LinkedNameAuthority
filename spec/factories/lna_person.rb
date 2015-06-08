FactoryGirl.define do
  factory :lna_person do |p|
    p.dc_netid                'f12345f'
    p.foaf_name               'Jane A. Doe'
    p.foaf_given_name         'Jane'
    p.foaf_family_name        ['Doe']
    p.foaf_title              'Dr.'
    p.foaf_image              'http://ld.dartmouth.edu/api/person/F12345F/img'
    p.foaf_mbox               'mailto:jane.a.doe@dartmouth.edu'
    p.foaf_mbox_sha1sum       'kjflakjfldjskflaskjfdsfdfadfsdfdf'
    p.foaf_homepage           'http://janeadoe.dartmouth.edu'
    p.foaf_publications       'http://dac.dartmouth.edu/person/F12345F'
    p.foaf_workplace_homepage 'http://engineering.dartmouth.edu'
  end
end
