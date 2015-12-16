require 'rails_helper'
require 'fedora_id'

RSpec.describe "Person/Account API", type: :request do
  
  before :all do
    https!
    @jane = FactoryGirl.create(:jane)
    @person_id = FedoraID.shorten(@jane.id)
  end

  # after all delete person

  describe 'POST person/:person_id/account(/:id)' do
    it 'returns error when user not authenticated' do
      post "/person/#{@person_id}/account", { format: :jsonld }
      expect(response).not_to be_success
    end

    describe 'when user is authenticated' do
      include_context 'authenticate user'

      describe 'succesfully adds new account' do 
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
        end
      
        it 'increases number of accounts' do
          expect(@jane.accounts.count).to be 1
          expect(@jane.accounts.first.title).to eq 'ORCID'
        end
      
        it 'return a status code of 201' do
          expect(response).to have_http_status(:created)
        end

        it 'return correct location header' do
          expect(response.location).to match %r{/person/#{@person_id}#[a-zA-Z0-9-]+}
        end

        it 'returns body with @id.' do
          expect(response.body).to match %r{"@id":"#{Regexp.escape(root_url)}person/#{@person_id}/account/[a-zA-Z0-9-]+}
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
    describe 'when user is authenticated' do
      it 'returns a status code of 200'
      it 'returns a body containing...'
      
    end
  end

  describe 'DELETE person/:person_id/account/:id' do
    describe 'when user is authenticated' do
      it 'returns a status code of 200'
      it 'returns body containing...'
    end
  end

  
end
