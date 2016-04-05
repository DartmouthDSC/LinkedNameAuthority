FactoryGirl.define do
  factory :person_hash, class: Hash do
#    netid           'd00000k'  
    person          { {
                        full_name:  'Jane Doe',
                        given_name:  'Jane',
                        family_name: 'Doe',
                        mbox:        'Jane.Doe@dartmouth.edu'
                      } }
    
    membership      { {
                        primary: true,
                        title:   'Professor',
                        org:      { label:     'Thayer School of Engineering',
                                    alt_label: ['Thayer'],
                                    hr_id:     '1234' }
                      } }
    
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

  factory :doc_hash, class: Hash do
    author_list      ['Doe, Jane', 'Smith, John']
    publisher        'New England Press'
    date             '2001-12-31'
    title            'Car Emissions in New England'
    page_start       '345'
    page_end         '364'
    pages            '19'
    volume           '4'
    issue            '1'
    number           '2'
    doi              'http://dx.doi.org/11.1047/02.slr.0400437526.63978.vc'
    abstract         'Lorem ipsum...'
    elements_id      '12345'
    
    initialize_with { attributes }
    to_create       {}
  end
end
