require 'rails_helper'
require 'airborne'
require 'fedora_id'

RSpec.describe "Person/Works API", type: :request do
  include_context 'forces https requests'
  include_context 'creates test person'

  # Add documents to test person.
  before :context do
    @article = FactoryGirl.create(:article, collection: @jane.collections.first)
    @license = FactoryGirl.create(:license, document: @article)
    expect(@jane.collections.first.documents.count).to eql 1
    @jane_short_id = "#{FedoraID.shorten(@jane.id)}"
  end

  describe 'GET person/:person_id/works' do
    include_examples 'successful request'
    
    before :context do
      get "/person/#{@jane_short_id}/works", format: :jsonld
    end

    it 'returns body with @id' do
      expect_json(:@id => "#{root_url}person/#{@jane_short_id}/works")
    end
                  
    it 'return body with @type' do
      expect_json(:@type => 'bibo:Collection')
    end
    
    it 'returns body with @graph' do
      expect_json_sizes(:@graph => 1)
    end
    
    it 'return body with article title' do
      expect_json('@graph.0', :'dc:title' => @article.title)
    end
  end

  describe 'GET persons/:person_id/works/:start_date' do
    before :context do
      @article2 = FactoryGirl.create(:article, date: 'February 15, 2001',
                                     collection:  @jane.collections.first)
    end

    it 'returns two articles if start date is before both articles were published' do
      get "/person/#{@jane_short_id}/works/2000-01-15", format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 2)
    end
    
    it 'returns one article if start date is before one article was published' do
      get "/person/#{@jane_short_id}/works/2001-02-15", format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 1)
    end

    it 'return no articles if start date after both articles were published' do
      get "/person/#{@jane_short_id}/works/2001-02-16", format: :jsonld
      expect_status :ok
      expect_json_sizes(:@graph => 0)
    end
  end
end
