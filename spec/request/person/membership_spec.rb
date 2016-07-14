require 'rails_helper'
require 'airborne'

RSpec.describe "Person/Membership API", type: :request, https: true do
  include_context 'creates test person'

  before :all do
    @org_id = FedoraID.shorten(@jane.primary_org.id)
  end

  let(:required_body) {
    {
      'org:organization'     => organization_url(@org_id),
      "vcard:title"          => "Professor of Engineering",
      "owltime:hasBeginning" => "2015-08-20"
    }.to_json
  }
  
  shared_context 'get membership id' do
    before :context do
      @id = FedoraID.shorten(@jane.memberships.first.id)
      @path = person_membership_path(person_id: @person_id, id: @id)
    end
  end
  
  describe 'POST person/:person_id/membership(/:id)' do
    include_examples 'requires authentication and authorization' do
      let(:path)   { person_membership_index_path(person_id: @person_id) }
      let(:action) { 'post' }
      let(:body)   { required_body }
    end
        
    describe 'when authorized', authenticated: true, admin: true do
      include_examples 'throws error when fields missing' do
        let(:path) { person_membership_index_path(person_id: @person_id) }
        let(:action) { 'post' }
      end
      
      describe 'succesfully adds new account' do
        include_examples 'successful POST request'
        
        before :context do
          body = {
            'org:organization'      => organization_url(id: @org_id),
            'vcard:email'           => "jane.doe@dartmouth.edu",
            "vcard:title"           => "Professor of Engineering",
            "vcard:street-address"  => "14 Engineering Dr.",
            "vcard:postal-code"     => "03755",
            "vcard:country-name"    => "United States",
            "vcard:locality"        => "Hanover, NH",
            "vcard:post-office-box" => "1234",
            "owltime:hasBeginning"  => "2015-08-20",
            "owltime:hasEnd"        => ""
          }
          post person_membership_index_path(person_id: @person_id), body.to_json, {
                 'ACCEPT'       => 'application/ld+json',
                 'CONTENT_TYPE' => 'application/ld+json'
               }
          @mem = @jane.memberships.first
          @id = FedoraID.shorten(@mem.id)
        end
      
        it 'increases number of accounts' do
          expect(@jane.memberships.count).to be 1
          expect(@jane.memberships.first.title).to eq 'Professor of Engineering'
        end
      
        it 'return correct location header' do
          expect_header('Location', "/person/#{@person_id}##{@id}")
        end

        describe 'response body' do
          it 'contains @id' do 
            expect_json(:@id => person_membership_url(person_id: @person_id, id: @id))
          end

          it 'contains title' do
            expect_json(:'vcard:title' => @mem.title)
          end
          
          it 'contains email' do
            expect_json(:'vcard:email' => @mem.email)
          end

          it 'contains post office box' do
            expect_json(:'vcard:post-office-box' => @mem.pobox)
          end
        end
      end
      
      it 'returns 404 if person_id is invalid' do
        post person_membership_index_path(person_id: "dfklajdlfkjasldfj"), { format: :jsonld }
        expect_status :not_found
      end
    end
  end

  describe 'PUT person/:person_id/membership/:id' do
    include_context 'get membership id'

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
            'org:organization'      => organization_url(@org_id),
            'vcard:email'           => "jane.doe@dartmouth.edu",
            "vcard:title"           => "Associate Professor of Engineering",
            "vcard:street-address"  => "14 Engineering Dr.",
            "vcard:postal-code"     => "03755",
            "vcard:country-name"    => "United States",
            "vcard:locality"        => "Hanover, NH",
            "vcard:post-office-box" => "1234",
            "owltime:hasBeginning"  => "2015-08-20",
            "owltime:hasEnd"        => ""
          }
          put @path, body.to_json, {
                'ACCEPT'       => 'application/ld+json',
                'CONTENT_TYPE' => 'application/ld+json'
              }
          @jane.reload
          @mem = @jane.memberships.first
        end

        it 'updates membership title in fedora store' do
          expect(@mem.title).to eql 'Associate Professor of Engineering'
        end
        
        describe 'response body' do
          it 'contains new membership title' do
            expect_json(:'vcard:title' => @mem.title)
          end

          it 'contains email' do
            expect_json(:'vcard:email' => @mem.email)
          end
        end
      end
    end
  end

  describe 'DELETE person/:person_id/membership/:id' do
    include_context 'get membership id'

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
          @jane.reload
        end
        
        it 'membership is deleted from fedora store' do
          expect(@jane.memberships.count).to eq 0
        end
      end
      
      it 'returns 404 if id is invalid' do
        delete person_membership_path(person_id: @person_id, id: 'blahblahblah'),
               { format: :jsonld }
        expect_status :not_found
      end
    end
  end
end
