FactoryGirl.define do
  factory :omniauth_hash, class: OmniAuth::AuthHash do
    skip_create

    transient do
      name 'Jane A. Doe'
      user 'Jane A. Doe@DARTMOUTH.EDU'
      affil 'DART'
      netid 'f12345f'
    end 
    
    provider :cas
    uid '1234567890'

    info do
      {
        name: name,
        nickname: user,
      }
    end

    extra do
      {
        affil: affil,
        alumniid: '00000000',
        authType: 'OAM',
        did: 'HDf12345f',
        netid: netid,
        nolijName: name,
        uid: '1234567890',
        user: user,      
      }
    end

    credentials do
      {
        ticket: 'mock-ticket',
      }
    end
    
  end
end
    
        
