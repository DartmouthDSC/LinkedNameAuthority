FactoryGirl.define do
  factory :thayer_prof, class: Lna::Membership do
    title          'Professor of Engineering'
    email          'mailto:jane.a.doe@dartmouth.edu'
    street_address '14 Engineering Dr.'
    pobox          'HB 0000'
    locality       'Hanover, NH'
    postal_code    '03755'
    country_name   'United States'
    member_during  ''
    person         { FactoryGirl.create(:jane) } 
    organization   { FactoryGirl.create(:thayer) }
    
  end
end
