require 'rails_helper'
require 'airborne'

RSpec.describe "Organizations API", type: :request, https: true do
  before :context do 
    @org = FactoryGirl.create(:thayer)
  end

  describe 'GET organizations/' do
    before :context do
      get organizations_path, format: :jsonld
    end

    it 'return status code of 200' do
      expect_status :ok
    end

    it 'returns graph with one organization' do
      expect_json_sizes(:@graph => 1)
    end

    it 'returns identifier' do
      expect_json('@graph.0', :'org:identifier' => @org.hr_id)
    end
    
    it 'returns sub organizations' do
      expect_json('@graph.0', :'org:subOrganizationOf' => [])
    end
    
    it 'returns pref label' do
      expect_json('@graph.0', :'skos:prefLabel' => @org.label)
    end
    
    it 'returns alt label' do
      expect_json('@graph.0', :'skos:altLabel' => @org.alt_label)
    end

    it 'returns purpose' do
      expect_json('@graph.0', :'org:purpose' => @org.kind)
    end

    it 'returns hinman box' do
      expect_json('@graph.0', :'vcard:post-office-box' => @org.hinman_box)
    end

    it 'includes link headers' do
      expect_header('Link', "<#{organizations_url(page: 1)}>; rel=\"first\", <#{organizations_url(page: 1)}>; rel=\"last\"")
    end
  end

  describe 'POST organizations/' do
    let(:request) {
      post organizations_path, body.to_json, {
             'ACCEPT' => 'application/ld+json',
             'CONTENT_TYPE' => 'application/ld+json'
           }
    }
    let(:body) { {} }
    
    context 'when searching by skos:prefLabel' do
      context 'when search term matches' do
        let(:body) { { 'skos:prefLabel' => 'engineering thayer' } }

        it 'returns 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end
      
      context 'when search term does not match' do
        let(:body) { { 'skos:prefLabel' => 'Computer Science Department' } }
        
        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
        
        it 'includes link headers' do
          request
          expect_header('Link', "<#{organizations_url(page: 1)}>; rel=\"first\", <#{organizations_url(page: 1)}>; rel=\"last\"")
        end
      end
    end

    context 'when searching by skos:altLabel' do
      context 'when search term matches' do
        let(:body) { { 'skos:altLabel' => 'thayer school' } }

        it 'returns 1 result' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 1)
        end
      end

      context 'when search term does not match' do
        let(:body) { { 'skos:altLabel' => 'thay' } }

        it 'returns 0 results' do
          request
          expect_status :ok
          expect_json_sizes(:@graph => 0)
        end
      end
    end

    context 'when searching by org:subOrganizationOf' do
      before :context do
        @provost = FactoryGirl.create(:provost)
        @org.super_organizations << @provost
        @org.save
      end

      context 'when search term matches' do
        context 'by org pref label' do
          let(:body) { { 'org:subOrganizationOf' => 'provost' } }

          it 'returns 1 result' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 2) # super org node will also be returned
          end
        end
        
        context 'by uri' do
          let(:body) { { 'org:subOrganizationOf' =>
                         organization_url(FedoraID.shorten(@provost.id)) } }

          it 'returns 1 result' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 2) # super org node will also be returned
          end
        end
      end
      
      context 'when search term does not match' do
        context 'by org pref label' do
          let(:body) { { 'org:subOrganizationOf' => 'prov' } }

          it 'returns 0 results' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 0)
          end
        end
        
        context 'by uri' do
          let(:body) { { 'org:subOrganizationOf' => organization_url('blah-blah-blah-1234') } }

          it 'returns 0 results' do
            request
            expect_status :ok
            expect_json_sizes(:@graph => 0)
          end
        end
      end
    end
  end
end
