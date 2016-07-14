require 'rails_helper'
require 'airborne'

RSpec.describe "Change Event API", type: :request, https: true do
  let(:required_body) {
    {
      "prov:atTime"    => "2012-12-01",
      "dc:description" => "A wild organziation appeared"
    }.to_json
  }
  
  describe 'POST organization/:id_from/change_to/:id_to' do
    before :context do
      @old_thayer = FactoryGirl.create(:old_thayer)
      @thayer = FactoryGirl.create(:thayer)

      @path = change_event_path(FedoraID.shorten(@old_thayer.id), FedoraID.shorten(@thayer.id))
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
      
      describe 'creates change event' do
        include_examples 'successful POST request'
        
        before :context do
          @count = Lna::Organization::ChangeEvent.count

          body = {
            "prov:atTime" => "2012-12-01",
            "dc:description" => "A wild organziation appeared"
          }.to_json
          
          post @path, body, {
            "ACCEPT"       => 'application/ld+json',
            "CONTENT_TYPE" => 'application/ld+json'
          }
          
          @id = json_body[:@id][1..-1]
          @change_event = Lna::Organization::ChangeEvent.find(FedoraID.lengthen(@id))
        end

        it 'creates and saves a new change event' do
          expect(Lna::Organization::ChangeEvent.count).to eq @count + 1
        end

        it 'sets changed_by in id_from' do
          @old_thayer.reload
          expect(@old_thayer.changed_by).to eq @change_event
        end
        
        it 'sets resulted_from in id_to' do
          @thayer.reload
          expect(@thayer.resulted_from).to eq @change_event
        end
        
        it 'returns correct location header' do
          expect_header('Location', organization_path(FedoraID.shorten(@thayer.id)) + '#' + @id)
        end

        describe 'response body' do
           it 'contains description' do
            expect_json(:'dc:description' => 'A wild organziation appeared')
          end
          
          it 'contains date' do
            expect_json(:'prov:atTime' => date { |v| expect(v).to eq Date.parse('2012-12-01') } )
          end

          it 'contains resulting organization' do
            expect_json(:'org:resultingOrganization' =>
                         [organization_url(FedoraID.shorten(@thayer.id))])
          end

          it 'contains original organization' do
            expect_json(:'org:originalOrganization' =>
                         [organization_url(FedoraID.shorten(@old_thayer.id))])
          end
        end
      end
    end
  end

  describe 'POST organization/:organization_id/end' do
    before :context do
      @thayer = FactoryGirl.create(:thayer)
      @path = organization_end_path(FedoraID.shorten(@thayer.id))
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

      describe 'creates historic organization' do
        include_examples 'successful POST request'

        before :context do
          @count = Lna::Organization::Historic.count

          body = {
            "prov:atTime"    => "2012-12-01",
            "dc:description" => "A wild organziation appeared"
          }.to_json

          post @path, body, {
            "ACCEPT"       => 'application/ld+json',
            "CONTENT_TYPE" => 'application/ld+json'
          }
        end

        it 'increased number of historic organizations' do
          expect(Lna::Organization::Historic.count).to eq @count + 1
        end

        it 'returns correct location header' do
          expect_header('Location', organization_path(FedoraID.shorten(@thayer.id)))
        end
        
        describe 'response body' do
          it 'contains id' do
            expect_json(:@id => organization_url(FedoraID.shorten(@thayer.id)))
          end
          
          it 'contains start date' do
            expect_json(:'owltime:hasBeginning' =>
                         date { |v| expect(v).to eq Date.parse('2000-01-01') } )
          end
              
          it 'contains end date' do
            expect_json(:'owltime:hasEnd' =>
                         date { |v| expect(v).to eq Date.parse('2012-12-01') } )
          end
        end
      end
    end
  end
end
