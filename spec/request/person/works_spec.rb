require 'rails_helper'
require 'airborne'

RSpec.describe "Person/Works API", type: :request, https: true do
  include_context 'creates test person'

  # Add documents to test person.
  before :context do
    @article = FactoryGirl.create(:article, collection: @jane.collections.first)
    @license = FactoryGirl.create(:license, document: @article)
    expect(@jane.collections.first.documents.count).to eql 1
    @jane_short_id = FedoraID.shorten(@jane.id)
  end

  describe 'GET person/:person_id/works' do
    include_examples 'successful request'
    
    before :context do
      get person_works_path(person_id: @jane_short_id), format: :jsonld
    end

    context 'response body' do 
      it 'contains @id' do
        expect_json(:@id => person_works_url(person_id: @jane_short_id))
      end
                  
      it 'contains @type' do
        expect_json(:@type => 'bibo:Collection')
      end
      
      it 'contains primary topic' do
        expect_json(:'foaf:primaryTopic' => person_url(id: @jane_short_id))
      end
      
      it 'contains @graph with one article' do
        expect_json_sizes(:@graph => 1)
      end
      
      context 'article in graph' do 
        it 'contains title' do
          expect_json('@graph.0', :'dc:title' => @article.title)
        end
        
        it 'contains @id' do
          expect_json('@graph.0', :@id => work_url(id: FedoraID.shorten(@article.id)))
        end
          
        it 'contains creator' do
          expect_json('@graph.0', :'dc:creator' => person_url(id: @jane_short_id))
        end
      end
    end
  end

  describe 'GET persons/:person_id/works/:start_date' do
    before :context do
      @article2 = FactoryGirl.create(:article, date: 'February 15, 2001',
                                     collection:  @jane.collections.first)
    end

    it 'returns two articles if start date is before both articles were published' do
      get person_works_path(person_id: @jane_short_id, start_date: '2000-01-15'), format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 2)
    end
    
    it 'returns one article if start date is before one article was published' do
      get person_works_path(person_id: @jane_short_id, start_date: '2001-02-15'), format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 1)
    end

    it 'return no articles if start date after both articles were published' do
      get person_works_path(person_id: @jane_short_id, start_date: '2001-02-16'), format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 0)
    end
  end
end
