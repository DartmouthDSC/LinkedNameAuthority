require 'rails_helper'
require 'symplectic/elements/publications'

RSpec.describe Symplectic::Elements::Publications do
  describe '.get' do
    context 'when querying for list of publications' do
      before :context do
        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 1, detail: 'full' })
          .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                     headers:  { 'Content-Type' => 'application/atom+xml' })

        @publications = Symplectic::Elements::Publications.get(netid: 'f001m9b')
      end

      subject { @publications }
      
      it 'request the correct resource' do
        expect(
          a_get_elements('/users/username-f001m9b/publications',
                         query: { page: 1, detail: 'full' })
        ).to have_been_made  
      end
      
      it 'returns array of Symplectic::Elements::Publication' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::Publication
      end
      
      it 'return correct number of publications' do
        expect(subject.count).to eq 25
      end
    end

    context 'when querying for publications recently modified' do
      before :context do
        @since = '2016-06-22T11:23:57-04:00'
        
        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 1, detail: 'full', :'modified-since' => @since })
          .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                     headers:  { 'Content-Type' => 'application/atom+xml' })

        Symplectic::Elements::Publications.get(netid: 'f001m9b',
                                               modified_since: DateTime.parse(@since))
      end

      it 'request the correct resource' do
        expect(
          a_get_elements('/users/username-f001m9b/publications',
                         query: { page: 1, detail: 'full', :'modified-since' => @since })
        ).to have_been_made
      end
    end
  end

  describe '.get_all' do
    context 'when querying for a list of users' do
      before :context do
        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 1, detail: 'full' })
          .to_return(status: 200, body: fixture('jb-publications-1.xml'),
                     headers:  { 'Content-Type' => 'application/atom+xml' })

        stub_get_elements('/users/username-f001m9b/publications',
                          query: { page: 2, detail: 'full' })
          .to_return(status: 200, body: fixture('jb-publications-2.xml'),
                     headers:  { 'Content-Type' => 'application/atom+xml' })

        @publications = Symplectic::Elements::Publications.get_all(netid: 'f001m9b')
      end

      subject { @publications }
      
      it 'request the correct resource' do
        expect(
          a_get_elements('/users/username-f001m9b/publications',
                         query: { page: 1, detail: 'full' })
        ).to have_been_made
        expect(
          a_get_elements('/users/username-f001m9b/publications',
                         query: { page: 2, detail: 'full' })
        ).to have_been_made  
      end
      
      it 'returns array of Symplectic::Elements::Publication' do
        expect(subject).to be_an Array
        expect(subject.first).to be_instance_of Symplectic::Elements::Publication
      end
      
      it 'returns correct number of publications' do
        expect(subject.count).to eq 26
      end
    end
  end
end
