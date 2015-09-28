FactoryGirl.define do
  factory :thayer, class: Lna::Organization do
    label      'Thayer School of Engineering'
    alt_label  ['Engineering School', 'Thayer']
    code       'THAY'
    begin_date '2000-01-01'

    factory :old_thayer, class: Lna::Organization::Historic do
      code       'THAYER'
      begin_date '1990-01-01'
      end_date   '2000-01-01'
    end
  end
end
