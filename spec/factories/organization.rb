FactoryGirl.define do
  factory :thayer, class: Lna::Organization do
    label        'Thayer School of Engineering'
    alt_label    ['Engineering School', 'Thayer']
    hr_id        '1234'
    kind         'SCH'
    hinman_box   '1000'
    begin_date   '2000-01-01'

    factory :old_thayer, class: Lna::Organization::Historic do
      begin_date         '1990-01-01'
      end_date           '2000-01-01'
      hinman_box         '1111'
      historic_placement '{}'
    end
  end

  # Organization factory with super and sub organizations.
  factory :library, class: Lna::Organization do
    label 'Dartmouth College Library'
    alt_label  ['Library']
    hr_id      '5678'
    kind       'SUBDIV'
    hinman_box '6025'
    begin_date '1974-01-01'

    # Using after :build was not setting sub_organizations.
    after(:create) do |library|
      library.sub_organizations << FactoryGirl.create(:dltg)
      library.super_organizations << FactoryGirl.create(:provost)
      library.save
    end
  end

  factory :dltg, class: Lna::Organization do
    label      'Digital Library Technologies Group'
    alt_label  ['DLTG']
    hr_id      '0123'
    kind       'UNIT'
    hinman_box '6025'
    begin_date '1990-01-01'
  end

  factory :provost, class: Lna::Organization do
    label      'Office of the Provost'
    alt_label  ['Provost']
    hr_id      '0001'
    kind       'DIV'
    hinman_box '0000'
    begin_date '1970-01-01'
  end
end
