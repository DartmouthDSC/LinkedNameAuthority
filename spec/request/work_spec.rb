require 'rails_helper'
require 'airborne'
require 'fedora_id'

RSpec.describe "Work API", type: :request do
  include_context 'forces https requests'
  include_context 'creates test person'

  shared_context 'get work id' do
    before :context do
      @id = FedoraID.shorten(@jane.collections.first.documents.first.id)
      @path = "/work/#{@id}"
    end
  end
  
  describe 'POST work(/:id)' do
    include_examples 'requires authentication' do
      let(:path) { "/work" }
      let(:action) { 'post' }
    end
        
    describe 'when authenticated' do
      include_context 'authenticate user'
      
      describe 'succesfully adds new account' do
        include_examples 'successful POST request'
        
        before :context do    
          body = {
            "bibo:doi" => "http://dx.doi.org/10.1002/9781118829059.wbihms321",
            "bibo:uri" => ["http://onlinelibrary.wiley.com/doi/10.1002/9781118829059.wbihms321/abstract"],
            "bibo:volume" => "3",
            "bibo:pages" => "24",
            "bibo:pageStart" => "473",
            "bibo:pageEnd" => "497",
            "bibo:authorsList" => "Bell, John and Ippolito, Jon",
            "dc:title" => "Diffused Museums",
            "dc:abstract" => "Lorem ipsum...",
            "dc:publisher" => "Wiley",
            "dc:date" => "2015",
            "dc:creator" => "#{root_url}person/#{FedoraID.shorten(@jane.id)}"
          }
          
          post "/work", body.to_json, {
                 'ACCEPT'       => 'application/ld+json',
                 'CONTENT_TYPE' => 'application/ld+json'
               }
          @id = FedoraID.shorten(@jane.collections.first.documents.first.id)
        end
      
        it 'increases number of documents in collection' do
          expect(@jane.collections.first.documents.count).to be 1
          expect(@jane.collections.first.documents.first.doi).to eq 'http://dx.doi.org/10.1002/9781118829059.wbihms321'
        end
      
        it 'return correct location header' do
          expect_header('Location', "/work/#{@id}")
        end

        it 'returns body with @id.' do
          expect_json(:@id => "#{root_url}work/#{@id}")
        end
      end
      
      it 'throw error if information is missing'

    end
  end

  describe 'PUT work/:id' do
    include_context 'get work id'

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
              "bibo:doi" => "http://dx.doi.org/10.1002/9781118829059.wbihms321",
              "bibo:uri" => ["http://onlinelibrary.wiley.com/doi/10.1002/9781118829059.wbihms321/abst\
ract"],
              "bibo:volume" => "3",
              "bibo:pages" => "24",
              "bibo:pageStart" => "473",
              "bibo:pageEnd" => "497",
              "bibo:authorsList" => "Bell, John and Ippolito, Jon",
              "dc:title" => "Diffused Museums and Making the Title Longer",
              "dc:abstract" => "Lorem ipsum...",
              "dc:publisher" => "Wiley",
              "dc:date" => "2015",
              "dc:creator" => "#{root_url}person/#{FedoraID.shorten(@jane.id)}"
          }
          put @path, body.to_json, {
                'ACCEPT'       => 'application/ld+json',
                'CONTENT_TYPE' => 'application/ld+json'
              }
          @jane.reload
        end

        it 'updates account name in fedora store' do
          expect(@jane.collections.first.documents.first.title).to eql 'Diffused Museums and Making the Title Longer'
        end
        
        it 'response body contains new account name' do 
          expect_json(:'dc:title' => "Diffused Museums and Making the Title Longer")
        end
      end

      it 'returns 404 if id is invalid' do
        put "/work/dfklajdlfkjasldfj", { format: :jsonld }
        expect_status :not_found
      end
    end
  end

  describe 'DELETE work/:id' do
    include_context 'get work id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end
    
    describe 'when authenticated' do
      include_context 'authenticate user'
      
      describe 'succesfully deletes work' do
        include_examples 'successful request'
        
        before :context do
          delete @path, {}, {
                   'ACCEPT'       => 'application/ld+json',
                   'CONTENT_TYPE' => 'application/ld+json'
                 }
          @jane.reload
        end
                
        it 'response body contains success' do
          expect_json(status: "success")
        end
        
        it 'account is deleted from fedora store' do
          expect(@jane.collections.first.documents.count).to eq 0
        end
      end
    end
  end
end
