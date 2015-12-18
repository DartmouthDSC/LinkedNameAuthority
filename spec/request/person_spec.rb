require 'rails_helper'
require 'airborne'
require 'api_helper'

# Note: These test must be run in the order that they are written.
RSpec.describe "Person API", type: :request do
  include_context 'forces https requests'
  
  describe 'POST person/' do
    include_examples 'requires authentication' do
      let(:path) { '/person' }
      let(:action) { 'post' }
    end
    
    describe 'when authenticated' do
      include_context 'authenticate user'

      before :context do
        body = {
          'foaf:name'       => 'John Bell',
          'foaf:givenName'  => 'John',
          'foaf:familyName' => 'Bell',
          'foaf:title'      => 'Dr.',
          'foaf:mbox'       => 'john.p.bell@dartmouth.edu',
          'foaf:image'      => 'http://dartmouth.edu/fictionalImageBank/12340.jpg',
          'foaf:homepage'   => 'http://novomancy.org/'
          'org:member'      => "#{root_url}/organization/"
        }

        post '/person', body.to_json, {
               "ACCEPT" => 'application/ld+json',
               "CONTENT_TYPE" => 'application/ld+json'
             }
        # get the id
      end
    
      it 'returns status code of 200' do
        expect(response).to be_success
      end

      it 'creates and saves new person'

      it 'returns correct location header'

      it 'returns body with @id'
      
    end
  end

  describe 'GET person/' do
    before :context do
      get '/person/1', { format: :jsonld }
    end
    
    it 'returns status code of 200' do
      expect(response).to be_success
    end

    it 'return content type of application/ld+json' do
      expect(response.content_type).to eq 'application/ld+json'
    end

    it 'redirects to page 1'
  end
end
