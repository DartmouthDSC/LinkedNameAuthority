require 'rails_helper'
require 'fedora_id'

RSpec.describe "Person/Account API", type: :request do
  include_context 'forces https requests'
  include_context 'creates test person'

  shared_context 'get account id' do
    before :context do
      @id = FedoraID.shorten(@jane.accounts.first.id)
      @path = "/person/#{@person_id}/account/#{@id}"
    end
  end
  
  describe 'POST person/:person_id/account(/:id)' do
    include_examples 'requires authentication' do
      let(:path) { "/person/#{@person_id}/account" }
      let(:action) { 'post' }
    end
        
    describe 'when authenticated' do
      include_context 'authenticate user'
      
      describe 'succesfully adds new account' do
        include_examples 'successful POST request'
        
        before :context do    
          body = {
            'dc:title'                    => 'ORCID',
            'foaf:accountName'            => 'http://orcid.org/0000-0000-0000-0000',
            'foaf:accountServiceHomepage' => 'http://orcid.org/'
          }
          post "/person/#{@person_id}/account", body.to_json, {
                 'ACCEPT'       => 'application/ld+json',
                 'CONTENT_TYPE' => 'application/ld+json'
               }
          @id = FedoraID.shorten(@jane.accounts.first.id)
        end
      
        it 'increases number of accounts' do
          expect(@jane.accounts.count).to be 1
          expect(@jane.accounts.first.title).to eq 'ORCID'
        end
      
        it 'return correct location header' do
          expect(response.location).to match %r{/person/#{@person_id}##{@id}}
        end

        it 'returns body with @id.' do
          expect(response.body).to match %r{"@id":"#{Regexp.escape(root_url)}person/#{@person_id}/account/#{@id}}
        end
      end
      
      it 'throw error if information is missing'

      it 'returns 404 if person_id is invalid' do
        post "/person/dfklajdlfkjasldfj/account", { format: :jsonld }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT person/:person_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end
    
    describe 'when authenticated' do
      include_context 'authenticate user'
      
      describe 'succesfully updates a new account' do
        include_examples 'successful request'
        
        before :context do
          body = {
            'dc:title'                    => 'ORCID',
            'foaf:accountName'            => 'http://orcid.org/0000-0000-0000-1234',
            'foaf:accountServiceHomepage' => 'http://orcid.org/'
          }
          put @path, body.to_json, {
                'ACCEPT'       => 'application/ld+json',
                'CONTENT_TYPE' => 'application/ld+json'
              }
          @jane.reload
        end

        it 'updates account name in fedora store' do
          expect(@jane.accounts.first.account_name).to eql 'http://orcid.org/0000-0000-0000-1234'
        end
        
        it 'response body contains new account name' do 
          expect(response.body).to match %r{"foaf:accountName":"http://orcid\.org/0000-0000-0000-1234"}
        end
      end
    end
  end

  describe 'DELETE person/:person_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end
    
    describe 'when authenticated' do
      include_context 'authenticate user'
      
      describe 'succesfully deletes account' do
        include_examples 'successful request'
        
        before :context do
          delete @path, {}, {
                   'ACCEPT'       => 'application/ld+json',
                   'CONTENT_TYPE' => 'application/ld+json'
                 }
          @jane.reload
        end
                
        it 'response body contains success' do
          expect(response.body).to match /success/
        end
        
        it 'account is deleted from fedora store' do
          expect(@jane.accounts.count).to eq 0
        end
      end
    end
  end
end
