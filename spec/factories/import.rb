FactoryGirl.define do
  factory :lna_hash, class: Hash do
    netid           'd00000k'  
    person          { { full_name: 'Jane Doe',
                        given_name: 'Jane',
                        family_name: 'Doe',
                        mbox: 'Jane.Doe@dartmouth.edu' } }
    
    membership      { { title: 'Professor' } }
    organization    { { label: 'Thayer School of Engineering',
                        dept_code: 'THAY' } }
    
    initialize_with { attributes }
    to_create       {}
  end
end
