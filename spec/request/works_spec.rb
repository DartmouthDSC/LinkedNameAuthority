require 'rails_helper'
require 'airborne'

RSpec.describe 'Works API', type: :request, https: true do
  before :context do
    @work = FactoryGirl.create(:article)
  end

  describe 'GET works/' do
    before :context do
      get works_path, format: :jsonld
    end

    it 'returns status code of 200' do
      expect_status :ok
    end

    it 'return graph with one work' do
      expect_json_sizes(:@graph => 1)
    end

    ## check fields

    it 'returns title' do
      expect_json('@graph.0', :'dc:title' => @work.title)
    end
    
    it 'returns author list' do
      expect_json('@graph.0', :'bibo:authorList' => @work.author_list)
    end
    
    it 'returns date' do
      expect_json('@graph.0', :'dc:date' => date { |v| expect(v).to eq @work.date })
    end
    
    it 'returns abstract' do
      expect_json('@graph.0', :'dc:abstract' => @work.abstract)
    end

    it 'return bibliographic citation' do
      expect_json('@graph.0', :'dc:bibliographicCitation' => @work.bibliographic_citation)
    end
    
    it 'returns subjects' do
      expect_json('@graph.0', :'dc:subject' => @work.subject)
    end
    
    it 'returns creator' do
      expect_json('@graph.0', :'dc:creator' =>
                               person_url(FedoraID.shorten(@work.collection.person.id)))
      
    end

    it 'returns doc_type' do
      expect_json('@graph.0', :'dc:type' => @work.doc_type)
    end

    it 'include link headers' do
      expect_header('Link', "<#{works_url(page: 1)}>; rel=\"first\", <#{works_url(page: 1)}>; rel=\"last\"")
    end
    
  end

  describe 'POST works/' do
    before :context do
      Lna::Collection::Document.create(title: 'Glaciers in the South Pole',
                                       doc_type: 'journal-article',
                                       author_list: ['Jane, Doe'],
                                       collection: @work.collection)
    end

    let(:request) {
      post works_path, body.to_json, {
             'ACCEPT' => 'application/ld+json',
             'CONTENT_TYPE' => 'application/ld+json'
           }
    }
    let(:body) { {} }
    
    context 'when searching by bibo:authorList' do
      context 'when search term matches' do
        let(:body) { { 'bibo:authorList' => 'Jane Doe' } }

        it 'returns 2 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 2)
        end
      end

      context 'when search term does not match' do
        let(:body) { { 'bibo:authorList' => 'John Smith' } }
        
        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by bibo:doi' do
      context 'when search term matches' do
        let(:body) { { 'bibo:doi' => 'http://dx.doi.org/19.1409/ddlp.1490' } }

        it 'return 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'bibo:doi' => 'http://dxb.doi.org/19.1409/ddlp' } }

        it 'return 0 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by dc:title' do
      let (:body) { { 'dc:title' => 'england car' } }
                      
      context 'when search term matches' do
        it 'returns 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'dc:title' => 'bunnies' } }
        
        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by bibo:abstract' do
      context 'when search term matches' do
        let(:body) { { 'bibo:abstract' => 'lorem' } }

        it 'returns 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'bibo:abstract' => 'bunnies' } }

        it 'returns 0 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by dc:subject' do
      context 'when search term matches' do
        let(:body) { { 'dc:subject' => 'environment global' } }

        it 'returns 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'dc:subject' => 'bunnies' } }
        
        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by org:member' do
      context 'when search term matches' do
        let(:body) { { 'org:member' => 'Thayer School of Engineering' } }

        it 'returns 1 result' do
          request
          puts json_body
          expect_status :ok
          expect_json_sizes(:@graph => 2)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'org:member' => 'provost' } }

        it 'returns 0 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end
  end
end
