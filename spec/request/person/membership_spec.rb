require 'rails_helper'
require 'airborne'
require 'fedora_id'

RSpec.describe "Person/Membership API", type: :request, https: true do
  include_context 'creates test person'

  before :all do
    @org_id = FedoraID.shorten(@jane.primary_org.id)
  end
  
  shared_context 'get membership id' do
    before :context do
      @id = FedoraID.shorten(@jane.memberships.first.id)
      @path = "/person/#{@person_id}/membership/#{@id}"
    end
  end
  
  describe 'POST person/:person_id/membership(/:id)' do
    include_examples 'requires authentication' do
      let(:path) { "/person/#{@person_id}/membership" }
      let(:action) { 'post' }
    end
        
    describe 'when authenticated', authenticated: true do
      describe 'succesfully adds new account' do
        include_examples 'successful POST request'
        
        before :context do
          body = {
            'org:organization'     => "#{root_url}organization/#{@org_id}",
            'vcard:email'          => "jane.doe@dartmouth.edu",
            "vcard:title"          => "Professor of Engineering",
            "vcard:street-address" => "14 Engineering Dr.",
            "vcard:postal-code"    => "03755",
            "vcard:country-name"   => "United States",
            "vcard:locality"       => "Hanover, NH",
            "owltime:hasBeginning" => "2015-08-20",
            "owltime:hasEnd"       => ""
          }
          post "/person/#{@person_id}/membership", body.to_json, {
                 'ACCEPT'       => 'application/ld+json',
                 'CONTENT_TYPE' => 'application/ld+json'
               }
          @id = FedoraID.shorten(@jane.memberships.first.id)
        end
      
        it 'increases number of accounts' do
          expect(@jane.memberships.count).to be 1
          expect(@jane.memberships.first.title).to eq 'Professor of Engineering'
        end
      
        it 'return correct location header' do
          expect_header('Location', "/person/#{@person_id}##{@id}")
        end

        it 'returns body with @id.' do
          expect_json(:@id => "#{root_url}person/#{@person_id}/membership/#{@id}")
        end
      end
      
      it 'throw error if information is missing'

      it 'returns 404 if person_id is invalid' do
        post "/person/dfklajdlfkjasldfj/membership", { format: :jsonld }
        expect_status :not_found
      end
    end
  end

  describe 'PUT person/:person_id/membership/:id' do
    include_context 'get membership id'

    include_examples 'requires authentication' do
      let(:path) { @path }
      let(:action) { 'put' }
    end
    
    describe 'when authenticated', authenticated: true do
      describe 'succesfully updates a new account' do
        include_examples 'successful request'
        
        before :context do
          body = {
            'org:organization'     => "#{root_url}organization/#{@org_id}",
            'vcard:email'          => "jane.doe@dartmouth.edu",
            "vcard:title"          => "Associate Professor of Engineering",
            "vcard:street-address" => "14 Engineering Dr.",
            "vcard:postal-code"    => "03755",
            "vcard:country-name"   => "United States",
            "vcard:locality"       => "Hanover, NH",
            "owltime:hasBeginning" => "2015-08-20",
            "owltime:hasEnd"       => ""
          }
          put @path, body.to_json, {
                'ACCEPT'       => 'application/ld+json',
                'CONTENT_TYPE' => 'application/ld+json'
              }
          @jane.reload
        end

        it 'updates membership title in fedora store' do
          expect(@jane.memberships.first.title).to eql 'Associate Professor of Engineering'
        end
        
        it 'response body contains new membership title' do
          expect_json(:'vcard:title' => "Associate Professor of Engineering")
        end
      end
    end
  end

  describe 'DELETE person/:person_id/membership/:id' do
    include_context 'get membership id'

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
          expect_json(status: 'success')
        end
        
        it 'membership is deleted from fedora store' do
          expect(@jane.memberships.count).to eq 0
        end
      end
    end
  end
end
