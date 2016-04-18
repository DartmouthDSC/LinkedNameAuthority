require 'rails_helper'
require 'airborne'

RSpec.describe "Person/Account API", type: :request, https: true do
  include_context 'creates test person'

  shared_context 'get account id' do
    before :context do
      @id = FedoraID.shorten(@jane.accounts.first.id)
      @path = person_account_path(person_id: @person_id, id: @id)
    end
  end
  
  describe 'POST person/:person_id/account' do
    before :context do
      @path = person_account_index_path(person_id: @person_id)
    end
    
    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'post' }
    end
        
    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'post' }
      end
      
      describe 'adds new account' do
        include_examples 'successful POST request'
        
        before :context do    
          body = {
            'dc:title'                    => 'ORCID',
            'foaf:accountName'            => 'http://orcid.org/0000-0000-0000-0000',
            'foaf:accountServiceHomepage' => 'http://orcid.org/'
          }
          post @path, body.to_json, {
                 'ACCEPT'       => 'application/ld+json',
                 'CONTENT_TYPE' => 'application/ld+json'
          }
          @acnt = @jane.accounts.first
          @id = FedoraID.shorten(@acnt.id)
        end
      
        it 'increases number of accounts' do
          expect(@jane.accounts.count).to be 1
          expect(@jane.accounts.first.title).to eq 'ORCID'
        end
      
        it 'return correct location header' do
          expect_header('Location', "/person/#{@person_id}##{@id}")
        end

        describe 'response body' do 
          it 'contains @id' do
            expect_json(:@id => person_account_url(person_id: @person_id, id: @id))
          end

          it 'contains title' do
            expect_json(:'dc:title' => @acnt.title) 
          end

          it 'contains account name' do
            expect_json(:'foaf:accountName' => @acnt.account_name)
          end

          it 'contains account service homepage' do
            expect_json(:'foaf:accountServiceHomepage' => @acnt.account_service_homepage)
          end
        end
      end

      it 'returns 404 if person_id is invalid' do
        post "/person/dfklajdlfkjasldfj/account", { format: :jsonld }
        expect_status :not_found
      end

      describe 'adds second account' do
        include_examples 'successful POST request'
        
        before :context do    
          body = {
            'dc:title'                    => 'Second Orcid',
            'foaf:accountName'            => 'http://orcid.org/1111-1111-1111-1111',
            'foaf:accountServiceHomepage' => 'http://orcid.org/'
          }
          post @path, body.to_json, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @jane.accounts.reload
          @acnt = @jane.accounts.select { |a| a.title == 'Second Orcid' }.first
          @id = FedoraID.shorten(@acnt.id)
        end

        after :context do
          @acnt.destroy
        end
        
        it 'increases number of accounts' do
          expect(@jane.accounts.count).to be 2
        end
      end
    end
  end

  describe 'PUT person/:person_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end
    
    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'put' }
      end
      
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
        
        describe 'response body' do
          it 'contains new account name' do 
            expect_json(:'foaf:accountName' => "http://orcid.org/0000-0000-0000-1234")
          end
        end
      end
    end
  end

  describe 'GET person/:person_id/orcid' do
    include_examples 'successful request'

    before :context do
      get person_orcid_path(person_id: @person_id), { format: :jsonld }
    end

    it 'person has an orcid account' do
      expect(@jane.accounts.first.title).to eq 'ORCID'
    end

    it 'returns ORCID account name.' do
      expect_json(:'foaf:accountName' => 'http://orcid.org/0000-0000-0000-1234')
    end
  end
  
  describe 'DELETE person/:person_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end
    
    describe 'when authenticated', authenticated: true do
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
          expect_json(:status => "success")
        end
        
        it 'account is deleted from fedora store' do
          expect(@jane.accounts.count).to eq 0
        end
      end
    end
  end
end
