require 'rails_helper'
require 'airborne'

RSpec.describe "Work API", type: :request, https: true do
  include_context 'creates test person'

  shared_context 'get work id' do
    before :context do
      @work = @jane.collections.first.documents.first
      @id = FedoraID.shorten(@work.id)
      @path = work_path(id: @id)
    end
  end
  
  describe 'POST work/' do
    include_examples 'requires authentication' do
      let(:path) { "/work" }
      let(:action) { 'post' }
    end
        
    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { work_index_path }
        let(:action) { 'post' }
      end
      
      describe 'adds new work' do
        include_examples 'successful POST request'
        
        before :context do    
          body = {
            "bibo:doi" => "http://dx.doi.org/10.1002/9781118829059.wbihms321",
            "bibo:uri" => ["http://onlinelibrary.wiley.com/doi/10.1002/9781118829059.wbihms321/abstract"],
            "bibo:volume" => "3",
            "bibo:pages" => "24",
            "bibo:pageStart" => "473",
            "bibo:pageEnd" => "497",
            "bibo:authorsList" => ["Bell, John", "Ippolito, Jon"],
            "dc:title" => "Diffused Museums",
            "dc:abstract" => "Lorem ipsum...",
            "dc:publisher" => "Wiley",
            "dc:date" => "2015",
            "dc:creator" => person_url(id: FedoraID.shorten(@jane.id))
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
          expect_header('Location', work_path(id: @id))
        end

        it 'returns body with @id.' do
          expect_json(:@id => work_url(id: @id))
        end
      end
    end
  end

  describe 'GET work/:id' do
    include_context 'successful request'
    include_context 'get work id'
    
    before :context do
      get @path, { format: :jsonld }
    end
    
    context 'response body' do
      it 'contains graph with 2 elements' do
        expect_json_sizes(:@graph => 2)
      end
      
      it 'contains @id' do
        expect_json('@graph.0', :@id => work_url(id: @id))
      end
      
      it 'contains doi' do
        expect_json('@graph.0', :'bibo:doi' => @work.doi)
      end

      it 'contains volume' do
        expect_json('@graph.0', :'bibo:volume' => @work.volume)
      end

      it 'contains pages' do
        expect_json('@graph.0', :'bibo:pages' => @work.pages)
      end

      it 'contains title' do
        expect_json('@graph.0', :'dc:title' => @work.title)
      end

      it 'contains creator' do
        expect_json('@graph.0', :'dc:creator' => person_url(id: FedoraID.shorten(@jane.id)))
      end

      it 'contains license refs' do
        expect_json('@graph.0', :'ali:license_ref' => [])
      end
    end
  end

  describe 'GET work/' do
    subject { get work_index_path, format: :jsonld }

    it 'redirects to GET works/' do
      expect(subject).to redirect_to('/works')
    end
  end
  
  describe 'PUT work/:id' do
    include_context 'get work id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end
    
    describe 'when authenticated', authenticated: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'put' }
      end
      
      describe 'updates a new account' do
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
              "bibo:authorsList" => ["Bell, John", "Ippolito, Jon"],
              "dc:title" => "Diffused Museums and Making the Title Longer",
              "dc:abstract" => "Lorem ipsum...",
              "dc:publisher" => "Wiley",
              "dc:date" => "2015",
              "dc:creator" => person_url(id: FedoraID.shorten(@jane.id))
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
        put work_path(id: 'dfklajdlfkjasldfj'), { format: :jsonld }
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
    
    describe 'when authenticated', authenticated: true do
      describe 'succesfully deletes work' do
        include_examples 'successful request'
        
        before :context do
          delete @path, {}, {
                   'ACCEPT'       => 'application/ld+json',
                   'CONTENT_TYPE' => 'application/ld+json'
                 }
          @jane.reload
        end
                
        it 'account is deleted from fedora store' do
          expect(@jane.collections.first.documents.count).to eq 0
        end
      end
    end
  end
end
