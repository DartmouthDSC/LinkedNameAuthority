FactoryGirl.define do
  factory :lna_appointment do |a|
    a.vcard_title          'Professor of Engineering'
    a.vcard_email          'mailto:jane.a.doe@dartmouth.edu'
    a.vcard_org            'http://ld.dartmouth.edu/api/org/thayer'
    a.vcard_street_address '14 Engineering Dr.'
    a.vcard_pobox          'HB 0000'
    a.vcard_locality       'Hanover, NH'
    a.vcard_postal_code    '03755'
    a.vcard_country_name   'United States'
    a.time_has_beginning   'July 1, 2014'
    a.time_has_end         'June 30, 2015'
  end
end
