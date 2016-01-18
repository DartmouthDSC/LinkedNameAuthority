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
  end

  describe 'GET person/:person_id/works' do
    include_examples 'successful request'
    
    before :context do
      get "/person/#{FedoraID.shorten(@jane.id)}/works", format: :jsonld
    end

    it 'returns body with @id' do
      expect_json(:@id => "#{root_url}person/#{FedoraID.shorten(@jane.id)}/works")
    end
                  
    it 'return body with @type' do
      expect_json(:@type => 'bibo:Collection')
    end
    
    it 'returns body with @graph'
    
    it 'return body with article title' do
      expect_json('@graph.0', :'dc:title' => @article.title)
    end
  end

  describe 'GET persons/:person_id/works/:start_date' do
    include_examples 'successful request'
    
    before :context do
      @article2 = FactoryGirl.create(:article, date: 'February 15, 2001',
                                     collection:  @jane.collections.first)
      get "/person/#{FedoraID.shorten(@jane.id)}/works/2000-02-15"
    end

    # should only return one article
    
    
  end
end
