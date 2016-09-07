require 'rails_helper'
require 'airborne'

RSpec.describe "Organization/Account API", type: :request, https: true do
  before :all do 
    @org = FactoryGirl.create(:thayer)
    @org_id = FedoraID.shorten(@org.id)
  end

  let(:required_body) {
    {
      'dc:title'                    => 'ORCID',
      'foaf:accountName'            => 'http://orcid.org/0000-0000-0000-0000',
      'foaf:accountServiceHomepage' => 'http://orcid.org/'
    }.to_json
  }
  
  shared_context 'get account id' do
    before :context do
      @id = FedoraID.shorten(@org.accounts.first.id)
      @path = organization_account_path(organization_id: @org_id, id: @id)
    end
  end
  
  describe 'POST organization/:organization_id/account' do
    before :context do
      @path = organization_account_index_path(organization_id: @org_id)
    end
    
    include_examples 'requires authentication and authorization' do
      let(:path)   { @path }
      let(:action) { 'post' }
      let(:body)   { required_body }
    end
        
    describe 'when authorized', authenticated: true, admin: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'post' }
      end
      
      describe 'succesfully adds new account' do
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
          @acnt = @org.accounts.first
          @id = FedoraID.shorten(@acnt.id)
        end
      
        it 'increases number of accounts' do
          expect(@org.accounts.count).to be 1
          expect(@org.accounts.first.title).to eq 'ORCID'
        end
      
        it 'return correct location header' do
          expect_header('Location', "/organization/#{@org_id}##{@id}")
        end

        describe 'response body' do 
          it 'contains @id' do
            expect_json(:@id => organization_account_url(organization_id: @org_id, id: @id))
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

      it 'returns 404 if organization_id is invalid' do
        post "/organization/dfklajdlfkjasldfj/account", { format: :jsonld }
        expect_status :not_found
      end
    end
  end

  describe 'PUT organization/:org_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication and authorization' do
      let(:path)   { @path }
      let(:action) { 'put' }
      let(:body)   { required_body }
    end
    
    describe 'when authorized', authenticated: true, admin: true do
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
          @org.reload
        end

        it 'updates account name in fedora store' do
          expect(@org.accounts.first.account_name).to eql 'http://orcid.org/0000-0000-0000-1234'
        end
        
        describe 'response body' do
          it 'contains new account name' do 
            expect_json(:'foaf:accountName' => "http://orcid.org/0000-0000-0000-1234")
          end
        end
      end
    end
  end
  
  describe 'DELETE organization/:organization_id/account/:id' do
    include_context 'get account id'

    include_examples 'requires authentication and authorization' do
      let(:path)   { @path }
      let(:action) { 'delete' }
      let(:body)   { {}.to_json }
    end
    
    describe 'when authorized', authenticated: true, admin: true do
      describe 'succesfully deletes account' do
        include_examples 'successful request'
        
        before :context do
          delete @path, {}, {
                   'ACCEPT'       => 'application/ld+json',
                   'CONTENT_TYPE' => 'application/ld+json'
                 }
          @org.reload
        end
                
        it 'response body contains success' do
          expect_json(:status => "success")
        end
        
        it 'account is deleted from fedora store' do
          expect(@org.accounts.count).to eq 0
        end
      end
    end
  end
end
