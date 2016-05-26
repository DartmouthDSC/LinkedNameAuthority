require 'rails_helper'
require 'airborne'

RSpec.describe "Persons API", type: :request, https: true do
  include_context 'creates test person'

  describe 'GET persons/' do
    before :context do
      get persons_path, {}, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
    end
    
    it 'returns status code of 200' do
      expect_status :ok
    end

    it 'return content type of application/ld+json' do
      expect_header_contains('Content-Type', 'application/ld+json')
    end

    it 'returns graph with one person' do
      expect_json_sizes(:@graph => 2)
    end

    it 'includes email' do
      expect_json('@graph.0', :'foaf:mbox' => 'jane.a.doe@dartmouth.edu')
    end

    it 'includes @id' do
      expect_json('@graph.0', :@id => person_url(id: FedoraID.shorten(@jane.id)))
    end
    
    it 'includes given name' do
      expect_json('@graph.0', :'foaf:givenName' => 'Jane')
    end

    it 'includes primary org' do
      expect_json('@graph.0',
             :'org:reportsTo' => organization_url(id: FedoraID.shorten(@jane.primary_org.id)))
    end

    it 'includes link headers' do
      expect_header('Link', "<#{persons_url(page: 1)}>; rel=\"first\", <#{persons_url(page: 1)}>; rel=\"last\"")
    end
  end
  
  describe 'POST person/' do
    let(:request) {
      post persons_path, body.to_json, {
             'ACCEPT' => 'application/ld+json',
             'CONTENT_TYPE' => 'application/ld+json'
           }
    }
    let(:body) { {} }
    
    context 'when searching by foaf:name' do
      context 'when search term matches' do
        let(:body) { { 'foaf:name' => 'doe jane' } }

        it 'returns one result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 2) #second item is graph is primary org
        end
      end
      
      context 'when search does not match' do
        let(:body) { { 'foaf:familyName' => 'doe john' } }

        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end
    
    context 'when searching by foaf:familyName' do
      context 'when search term matches' do
        let(:body) { { 'foaf:familyName' => 'doe' } }

        it 'returns one result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 2) #second item is graph is primary org
        end
      end

      context 'when search term does not match' do
        let(:body) { { 'foaf:familyName' => 'not doe' } }
        
        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
        
        it 'includes link headers' do
          request
          expect_header('Link',
                        "<#{persons_url(1)}>; rel=\"first\", <#{persons_url(1)}>; rel=\"last\"")
        end
      end
    end

    context 'when searching by foaf:givenName' do
      context 'when search term match' do
        let(:body) { { 'foaf:givenName' => 'jane' } }

        it 'returns one result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 2) #second item is graph is primary org
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'foaf:givenName' => 'not jane' } }

        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by org:member' do
      context 'when search term matches' do
        context 'by org pref label' do
          let(:body) { { 'org:member' => 'thayer school' } }

          it 'returns one result' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 2) #second item is graph is primary org
          end
        end
        
        context 'by org uri' do
          let(:body) { { 'org:member' =>
                         organization_url(FedoraID.shorten(@jane.primary_org.id)) } }

          it 'returns one result' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 2) #second item is graph is primary org
          end
        end
      end

      context 'when search term does not match' do
        context 'by org pref label' do
          let(:body) { { 'org:member' => 'science' } }

          it 'returns 0 results' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 0)
          end          
        end
        
        context 'by org uri' do
          let(:body) { { 'org:member' => organization_url('dfjasdfkj-987uf-99hkjfd') } }

          it 'returns 0 results' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 0)
          end
        end
      end
    end
  end
end
