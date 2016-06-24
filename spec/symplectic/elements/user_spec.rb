require 'rails_helper'
require 'symplectic/elements/user'

RSpec.describe Symplectic::Elements::User do
  before :all do
    api_object = Nokogiri::XML('<api:object category="user" id="12" proprietary-id="f001m9b" authenticating-authority="Dartmouth-WebAuth" username="F001M9B" last-modified-when="2016-06-15T04:08:27.24-04:00" href="https://localhost:9002/elements-secure-api/users/12?detail=ref" created-when="2015-09-24T11:01:31.613-04:00" type-id="1" type="person"><api:relationships href="https://localhost:9002/elements-secure-api/users/12/relationships"/></api:object>').elements.first
    @user = Symplectic::Elements::User.new(api_object)
  end
  
  describe '.new' do
    subject { @user }
    
    its(:id) { is_expected.to eq '12' }
    its(:proprietary_id) { is_expected.to eq 'f001m9b' }
  end

  describe '#publications' do
    context 'when querying for list of publications' do 
      before :context do
        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 1, detail: 'full' })
          .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })
  
        @publications = @user.publications
      end
    
      subject { @publications }
      
      it 'requests the correct resource' do
        expect(
          a_get_elements('/users/username-f001m9b/publications',
                         query: { page: 1, detail: 'full' })
        ).to have_been_made
      end
      
      it 'returns an array of Symplectic::Elements::Publication' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::Publication
      end
      
      it 'returns one publication' do
        expect(subject.count).to eq 25
      end
    end

    context 'when querying for list of publications since' do
      before :context do
        @since = '2016-06-22T13:35:19-04:00'
        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 1, detail: 'full', :'modified-since' => @since })
          .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                     headers: { 'Content-Type' => 'application/atom+xml' })
        
        @publications = @user.publications(modified_since: DateTime.parse(@since))
      end
      
      subject { @publications }

      it 'requests the correct resource' do
        expect(
          a_get_elements(
            '/users/username-f001m9b/publications',
            query: { page: 1, detail: 'full', :'modified-since' => @since }
          )
        ).to have_been_made
      end    
    end
  end
  
  describe '#all_publications' do
    before :context do
      stub_get_elements('/users/username-f001m9b/publications',
                        query: { page: 1, detail: 'full' })
        .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                   headers: { 'Content-Type' => 'application/atom+xml' })

      stub_get_elements('/users/username-f001m9b/publications',
                        query: { page: 2, detail: 'full' })
        .to_return(status: 200, body: fixture('jb-publications-2.xml'),
                   headers: { 'Content-Type' => 'application/atom+xml' })

      @publications = @user.all_publications
    end

    subject { @publications }

    it 'requests the correct resource' do
      expect(
        a_get_elements('/users/username-f001m9b/publications', query: { page: 1, detail: 'full' })
      ).to have_been_made
      expect(
        a_get_elements('/users/username-f001m9b/publications', query: { page: 2, detail: 'full' })
      ).to have_been_made
    end

    it 'returns array of Symplectic::Elements::Publication' do
      expect(@publications).to be_an Array
      expect(@publications.first).to be_instance_of Symplectic::Elements::Publication
    end

    it 'return correct number of records' do
      expect(@publications.count).to be 26
    end
  end
end
