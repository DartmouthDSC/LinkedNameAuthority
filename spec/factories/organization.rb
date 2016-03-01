FactoryGirl.define do
  factory :thayer, class: Lna::Organization do
    label        'Thayer School of Engineering'
    alt_label    ['Engineering School', 'Thayer']
    code         'THAY'
    begin_date   '2000-01-01'

    factory :old_thayer, class: Lna::Organization::Historic do
      code               'THAYER'
      begin_date         '1990-01-01'
      end_date           '2000-01-01'
      historic_placement '{}'
    end
  end

  # Organization factory with super and sub organizations.
  factory :library, class: Lna::Organization do
    label 'Dartmouth College Library'
    alt_label ['Library']
    code 'LIB'
    begin_date '1974-01-01'

    after(:build) do |library|
      library.sub_organizations << FactoryGirl.create(:dltg)
      library.super_organizations << FactoryGirl.create(:provost)
    end
  end

  factory :dltg, class: Lna::Organization do
    label 'Digital Library Technologies Group'
    alt_label ['DLTG']
    code 'DLTG'
    begin_date '1990-01-01'
  end

  factory :provost, class: Lna::Organization do
    label 'Office of the Provost'
    alt_label ['Provost']
    code 'PROV'
    begin_date '1970-01-01'
  end
end
