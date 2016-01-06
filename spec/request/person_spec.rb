require 'rails_helper'
require 'airborne'
require 'fedora_id'

# Note: These test must be run in the order that they are written.
RSpec.describe "Person API", type: :request do
  include_context 'forces https requests'

  before :all do
    @jane = FactoryGirl.create(:jane)
    @org_id = FedoraID.shorten(@jane.primary_org.id)
  end

  shared_context 'get person id' do
    before :context do
      @id = FedoraID.shorten(@jane.id)
      @path = "/person/#{@id}"
    end
  end

  describe 'GET person/' do
    include_context 'get person id'
    
    before :context do
      get @path, { format: :jsonld }
    end
    
    it 'returns status code of 200' do
      expect(response).to be_success
    end

    it 'return content type of application/ld+json' do
      expect(response.content_type).to eq 'application/ld+json'
    end

    it 'response body contains @id' do
      expect_json('@graph.0', :@id => "#{root_url}person/#{@id}")
    end

    it 'response body contains name' do
      expect_json('@graph.0', :'foaf:name' => 'Jane A. Doe')
    end
    
    it 'redirects to page 1 if no id is given'
  end
  
  describe 'POST person/' do
    include_examples 'requires authentication' do
      let(:path) { '/person' }
      let(:action) { 'post' }
    end
    
    describe 'when authenticated' do
      include_context 'authenticate user'

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
          'org:reportsTo'   => "#{root_url}organization/#{@org_id}"
        }

        post '/person', body.to_json, {
               "ACCEPT"       => 'application/ld+json',
               "CONTENT_TYPE" => 'application/ld+json'
             }
        m = /"@id":"#{Regexp.escape(root_url)}person\/([a-zA-Z0-9-]+)"/.match(response.body)
        @id = FedoraID.shorten(m[1])
      end

      after :context do
        Lna::Person.find(FedoraID.lengthen(@id)).destroy
      end
      
      it 'returns status code of 200' do
        expect(response).to be_success
      end

      it 'creates and saves new person' do
        expect(Lna::Person.count).to eq @count + 1
      end

      it 'returns correct location header' do
        expect_header('Location', "/person/#{@id}")
      end 

      it 'returns body with @id' do
        expect_json(:@id => "#{root_url}person/#{@id}")
      end
    end
  end

  describe 'PUT person/:id' do
    include_context 'get person id'
    
    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end

    describe 'when authenticated' do
      include_context 'authenticate user'
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
          'org:reportsTo'   => "#{root_url}organization/#{@org_id}"
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

  describe 'DELETE person/:id' do
    include_context 'get person id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end

    describe 'when authenticated' do
      include_context 'authenticate user'

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
