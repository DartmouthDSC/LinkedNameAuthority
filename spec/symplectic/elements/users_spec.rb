require 'rails_helper'
require 'symplectic/elements/users'

RSpec.describe Symplectic::Elements::Users do  
  describe '.get' do
    context 'when querying for list of users' do
      before :context do
        stub_get_elements('/users', query: { page: 1, detail: 'ref' })
          .to_return(status: 200, body: fixture('users-1.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })   
        
        @users = Symplectic::Elements::Users.get
      end
      
      subject { @users }
      
      it 'requests the correct resource' do
        expect(a_get_elements('/users', query: { page: 1, detail: 'ref' })).to have_been_made
      end

      it 'returns array of Symplectic::Elements::User' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::User
      end
      
      it 'returns correct number of users' do
        expect(subject.count).to eq 25
      end
    end

    context 'when querying for a user' do
      before :context do
        stub_get_elements('/users/username-f001m9b', query: { page: 1, detail: 'ref' })
          .to_return(status: 200, body: fixture('user-jb.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })
        
        @user = Symplectic::Elements::Users.get(netid: 'f001m9b')
      end
                          
      subject { @user }

      it 'requests the correct resource' do
        expect(
          a_get_elements('/users/username-f001m9b', query: { page: 1, detail: 'ref' })
        ).to have_been_made
      end
                
      it 'returns array of Symplectic::Elements::User' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::User
      end

      it 'returns one result' do
        expect(subject.count).to eq 1
      end

      it 'returns correct user' do
        expect(subject.first.id).to eq '12'
        expect(subject.first.proprietary_id).to eq 'f001m9b'
      end
    end

    context 'when querying for users recently modified' do
      before :context do
        @since = '2016-06-22T11:23:57-04:00'
        
        stub_get_elements('/users', query: { page: 1, detail: 'ref', :'modified-since' => @since })
          .to_return(status: 200, body: fixture('users-1.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })
        Symplectic::Elements::Users.get(modified_since: DateTime.parse(@since))
      end
      
      it 'requests the correct resource' do
        expect(
          a_get_elements('/users', query: { page: 1, detail: 'ref', :'modified-since' => @since })
        ).to have_been_made
      end
    end

    it 'raises error if querying with modified since and netid' do
      expect {
        Symplectic::Elements::Users.get(modified_since: DateTime.now, netid: 'd0000f')
      }.to raise_error Symplectic::Elements::RequestError
    end
  end

  describe '.get_all' do
    context 'when querying for list of users' do 
      before :context do
        stub_get_elements('/users', query: { page: 1, detail: 'ref' })
          .to_return(status: 200, body: fixture('users-1.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })
        
        stub_get_elements('/users', query: { page: 2, detail: 'ref' })
          .to_return(status: 200, body: fixture('users-2.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })

        @users = Symplectic::Elements::Users.get_all
      end

      subject { @users }
      
      it 'request the correct resource' do
        expect(a_get_elements('/users', query: { page: 1, detail: 'ref' })).to have_been_made
        expect(a_get_elements('/users', query: { page: 2, detail: 'ref' })).to have_been_made
      end

      it 'returns array of Symplectic::Elements::User' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::User
      end
      
      it 'returns correct number of users' do
        expect(subject.count).to eq 49
      end
    end
  end
end
