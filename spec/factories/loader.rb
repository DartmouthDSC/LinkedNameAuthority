FactoryGirl.define do
  factory :person_hash, class: Hash do
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

  factory :org_hash, class: Hash do
    label              'Library'
    alt_label          ['DLC', 'LIB']
    hr_id              '1234'
    kind               'SUBDIV'
    hinman_box         '0000'
    begin_date         '01-01-2001'
    end_date           nil
    super_organization { { label: 'Office of the Provost' } }

    initialize_with    { attributes }
    to_create          {}
  end
end
