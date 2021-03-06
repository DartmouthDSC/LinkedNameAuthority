require 'rails_helper'
require 'airborne'

RSpec.describe "Organization API", type: :request, https: true do
  before :all do
    @org = FactoryGirl.create(:library)
    @provost = @org.super_organizations.first
    @dltg = @org.sub_organizations.first
    FactoryGirl.create(:orcid_for_org, account_holder: @org)
  end

  let(:required_body) {
    {
      'skos:prefLabel'      => 'Dartmouth Information Technology Services',
      'owltime:hasBeginning' => '2013-06-01',
    }.to_json
  }

  shared_context 'get organization id' do
    before :context do
      @id = FedoraID.shorten(@org.id)
      @path = organization_path(id: @id)
    end
  end
  
  describe 'GET organization/:id' do 
    describe 'for active organization' do
      include_examples 'successful request'
      include_context 'get organization id'
      
      before :context do
        get @path, { format: :jsonld }
      end

      context 'response body' do
        it 'contains three children in @graph' do
          expect_json_sizes(:@graph => 4)
        end
        
        it 'contains @id' do
          expect_json('@graph.0', :@id => organization_url(id: @id))
        end
        
        it 'contains identifier' do
          expect_json('@graph.0', :'org:identifier' => @org.hr_id)
        end
        
        it 'contains sub organization' do
          subs = @org.sub_organization_ids.map{ |i| organization_url(id: FedoraID.shorten(i)) }
          expect_json('@graph.0', :'org:hasSubOrganization' => subs)
        end
        
        it 'contains super organization' do
          supers = @org.super_organization_ids.map{ |i| organization_url(id: FedoraID.shorten(i)) }
          expect_json('@graph.0', :'org:subOrganizationOf' => supers)
        end
        
        it 'contains pref label' do
          expect_json('@graph.0', :'skos:prefLabel' => @org.label)
        end
        
        it 'contains alt label' do
          expect_json('@graph.0', :'skos:altLabel' => @org.alt_label)
        end

        it 'contains purpose' do
          expect_json('@graph.0', :'org:purpose' => @org.kind)
        end

        it 'contains hinman box' do
          expect_json('@graph.0', :'vcard:post-office-box' => @org.hinman_box)
        end

        it 'contains account' do
          expect_json('@graph.0', :'foaf:account' =>
                                   ['#' + FedoraID.shorten(@org.accounts.first.id)])
        end
      end
    end

    describe 'for historic organization' do
      include_context 'successful request'
      before :context do 
        event = FactoryGirl.create(:hb_change)
        @old_org = event.original_organizations.first
        @old_org_id = FedoraID.shorten(@old_org.id)

        get organization_path(id: @old_org_id), { format: :jsonld }
      end

      context 'response body' do
        it 'contains historic placement' do
          expect_json('@graph.0', :'lna:historicPlacement' => @old_org.historic_placement)
        end
        
        it 'contains changed by' do
          expect_json('@graph.0', :'org:changedBy' => '#' + FedoraID.shorten(@old_org.changed_by.id))
        end

        it 'contains change by node in graph' do
          expect_json('@graph.1', :@type => 'org:ChangeEvent')
          expect_json('@graph.1',
                      :'org:originalOrganization' => [organization_url(@old_org_id)])
        end
      end
    end
  end

  describe 'GET admin/organization/' do
    subject { get admin_organization_path }
    
    it 'redirects to GET admin/organizations/' do
      expect(subject).to redirect_to('/admin/organizations')
    end
  end
  
  
  describe 'POST organization/' do
    include_examples 'requires authentication and authorization' do
      let(:path)   { organization_index_path }
      let(:action) { 'post' }
      let(:body)   { required_body }
    end
    
    describe 'when authorized', authenticated: true, admin: true do 
      include_examples 'throws error when fields missing' do
        let(:path) { organization_index_path }
        let(:action) { 'post' }
      end
      
      describe 'adds new organization' do
        include_examples 'successful POST request'
        
        before :context do
          @count = Lna::Organization.count
          body = {
            'org:identifier'         => '0021',
            'skos:prefLabel'         => 'Dartmouth Information Technology Services',
            'skos:altLabel'          => ['ITS'],
            'owltime:hasBeginning'   => '2013-06-01',
            'vcard:post-office-box'  => '0000',
            'org:purpose'            => 'SUBDIV',
            'org:subOrganizationOf'  => [organization_url(FedoraID.shorten(@provost.id))],
            'org:hasSubOrganization' => [organization_url(FedoraID.shorten(@dltg.id))]
          }

          post organization_index_path, body.to_json, {
                 "ACCEPT"       => 'application/ld+json',
                 "CONTENT_TYPE" => 'application/ld+json'
               }
          
          m = /#{Regexp.escape(root_url)}organization\/([a-zA-Z0-9-]+)/.match(json_body[:@id])
          @id = FedoraID.shorten(m[1])
          @its = Lna::Organization.find(FedoraID.lengthen(@id))
        end

        it 'creates and saves a new organization' do
          expect(Lna::Organization.count).to eq @count + 1
        end

        it 'adds super organization' do
          expect(@its.super_organizations.count).to eq 1
          expect(@its.super_organizations).to include @provost
        end
        
        it 'adds sub organization' do
          expect(@its.sub_organizations.count).to eq 1
          expect(@its.sub_organizations).to include @dltg
        end
        
        it 'returns correct location header' do
          expect_header('Location', organization_path(id: @id))
        end

        describe 'response body' do
           it 'contains pref label' do
            expect_json(:'skos:prefLabel' => 'Dartmouth Information Technology Services')
          end
          
          it 'contains alt labels' do
            expect_json(:'skos:altLabel' => ['ITS'])
          end

          it 'contains purpose' do
            expect_json(:'org:purpose' => 'SUBDIV')
          end

          it 'contains post office box' do
            expect_json(:'vcard:post-office-box' => '0000')
          end
        end
      end
    end
  end

  describe 'PUT organization/' do
    include_context 'get organization id'

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
      
      describe 'updates organization' do
        include_examples 'successful request'
        
        before :context do
          body = {
            'org:identifier'         => '0022',
            'skos:prefLabel'         => 'Dartmouth College Library',
            'skos:altLabel'          => ['Library'],
            'owltime:hasBeginning'   => '1974-01-01',
            'vcard:post-office-box'  => '0000',
            'org:purpose'            => 'SUBDIV',
            'org:subOrganizationOf'  => [organization_url(FedoraID.shorten(@provost.id))],
            'org:hasSubOrganization' => [organization_url(FedoraID.shorten(@dltg.id))]
          }
          put @path, body.to_json, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @org.reload
        end
        
        it 'updates hr id in fedora store' do
          expect(@org.hr_id).to eq '0022'
        end

        it 'keeps sub organizations' do
          expect(@org.sub_organizations).to eq [@dltg]
        end

        it 'keeps super organizations' do
          expect(@org.super_organizations).to eq [@provost]
        end
        
        it 'response body contains updated code' do
          expect_json(:'org:identifier' => '0022')
        end
      end
    end
  end

  describe 'DELETE organization/' do
    include_context 'get organization id'

    include_examples 'requires authentication and authorization' do
      let(:path)   { @path }
      let(:action) { 'delete' }
      let(:body)   { required_body }
    end

    describe 'when authorized', authenticated: true, admin: true do
      describe 'succesfully deletes organization' do
        include_examples 'successful request'

        before :context do
          @count = Lna::Organization.all.count
          delete @path, {}, {
            'ACCEPT' => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld_json',
          }
        end

        it 'response body contain success' do
          expect_json(status: 'success')
        end

        it 'organization is delete from fedora store' do
          expect(Lna::Organization.all.count).to eql @count - 1
        end
      end
    end
  end
end
