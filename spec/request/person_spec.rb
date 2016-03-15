require 'rails_helper'
require 'airborne'

# Note: These test must be run in the order that they are written.
RSpec.describe "Person API", type: :request, https: true do
  before :all do
    @jane = FactoryGirl.create(:jane)
    @org_id = FedoraID.shorten(@jane.primary_org.id)
  end

  shared_context 'get person id' do
    before :context do
      @id = FedoraID.shorten(@jane.id)
      @path = person_path(id: @id)
    end
  end

  describe 'GET person/:id' do
    include_context 'successful request'
    include_context 'get person id'
    
    before :context do
      get @path, { format: :jsonld }
    end
    
    context 'response body' do 
      it 'contains @id' do
        expect_json('@graph.0', :@id => person_url(id: @id))
      end

      it 'contains name' do
        expect_json('@graph.0', :'foaf:name' => @jane.full_name)
      end

      it 'contains family name' do
        expect_json('@graph.0', :'foaf:familyName' => @jane.family_name)
      end

      it 'contains email' do
        expect_json('@graph.0', :'foaf:mbox' => @jane.mbox)
      end

      it 'contains homepage' do
        expect_json('@graph.0', :'foaf:homepage' => @jane.homepage)
      end
    end
  end

  describe 'GET person/' do      
    subject { get person_index_path }
    
    it 'redirects to GET persons/' do
      expect(subject).to redirect_to('/persons')
    end
  end
  
  describe 'POST person/' do
    include_examples 'requires authentication' do
      let(:path) { person_index_path }
      let(:action) { 'post' }
    end
    
    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { person_index_path }
        let(:action) { 'post' }
      end

      describe 'adds new person' do
        include_examples 'successful POST request'
        
        before :context do
          @count = Lna::Person.all.count
          body = {
            'foaf:name'       => 'John Bell',
            'foaf:givenName'  => 'John',
            'foaf:familyName' => 'Bell',
            'foaf:title'      => 'Dr.',
            'foaf:mbox'       => 'john.p.bell@dartmouth.edu',
            'foaf:image'      => 'http://dartmouth.edu/fictionalImageBank/12340.jpg',
            'foaf:homepage'   => ['http://novomancy.org/'],
            'org:reportsTo'   => organization_url(id: @org_id)
          }
          
          post person_index_path, body.to_json, {
                 "ACCEPT"       => 'application/ld+json',
                 "CONTENT_TYPE" => 'application/ld+json'
               }
          m = /"@id":"#{Regexp.escape(root_url)}person\/([a-zA-Z0-9-]+)"/.match(response.body)
          @id = FedoraID.shorten(m[1])
        end
        
        it 'creates and saves new person' do
          expect(Lna::Person.count).to eq @count + 1
        end
        
        it 'returns correct location header' do
          expect_header('Location', person_path(id: @id))
        end 
        
        it 'returns body with @id' do
          expect_json(:@id => person_url(id: @id))
        end
      end    
    end
  end
    
  describe 'PUT person/:id' do
    include_context 'get person id'
    
    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end

    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'put' }
      end

      describe 'updates person' do
        include_examples 'successful request'
        before :context do
          body = {
            'foaf:name'       => 'Jane A. Doe',
            'foaf:givenName'  => 'Jane',
            'foaf:familyName' => 'Doe',
            'foaf:title'      => 'Dr.',
            'foaf:mbox'       => 'jane.doe@dartmouth.edu',
            'foaf:image'      => 'http://ld.dartmouth.edu/api/person/F12345F/img',
            'foaf:homepage'   => ['http://janeadoe.dartmouth.edu/'],
            'org:reportsTo'   => organization_url(id: @org_id)
          }
          
          put @path, body.to_json, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @jane.reload
        end
        
        it 'updates mbox in fedora store' do
          expect(@jane.mbox).to eq 'jane.doe@dartmouth.edu'
        end
        
        it 'response body contains updated mbox' do
          expect_json(:'foaf:mbox' => 'jane.doe@dartmouth.edu')
        end
      end
    end
  end

  describe 'DELETE person/:id' do
    include_context 'get person id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end

    describe 'when authenticated', authenticated: true do
      describe 'succesfully deletes person' do
        include_examples 'successful request'

        before :context do
          @count = Lna::Person.all.count
          delete @path, {}, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld_json',
          }
        end

        it 'response body contain success' do
          expect_json(status: 'success')
        end

        it 'person is delete from fedora store' do
          expect(Lna::Person.all.count).to eql @count - 1
        end
      end
    end
  end
end
