FactoryGirl.define do
  factory :lna_hash, class: Hash do
    netid           'd00000k'  
    person          { { full_name:  'Jane Doe',
                        given_name:  'Jane',
                        family_name: 'Doe',
                        mbox:        'Jane.Doe@dartmouth.edu' } }
    
    membership      { { primary: true,
                        title:   'Professor',
                        org:      { label:     'Thayer School of Engineering',
                                    alt_label: ['Thayer'],
                                    hr_id:     '1234' }   } }
    
    initialize_with { attributes }
    to_create       {}
  end
end
