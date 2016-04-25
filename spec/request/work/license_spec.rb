require 'rails_helper'
require 'airborne'

RSpec.describe 'Work/License API', type: :request, https: true do
  before :all do
    @work = FactoryGirl.create(:article)
    @work_id = FedoraID.shorten(@work.id)
  end

  shared_context 'get work id' do
    before :context do
      @id = FedoraID.shorten(@work.license_refs.first.id)
      @path = work_license_path(work_id: @work_id, id: @id)
    end
  end

  describe 'POST work/:work_id/license' do
    before :context do
      @path = work_license_index_path(work_id: @work_id)
    end

    include_examples 'requires authentication and authorization' do
      let(:path) { @path }
      let(:action) { 'post' }
    end

    describe 'when authorized', authenticated: true, editor: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'post' }
      end

      describe 'adds new license' do
        include_examples 'successful POST request'

        before :context do
          body = {
            'ali:start_date' => '2011-11-01',
            'ali:end_date'   => '2012-11-01',
            'ali:uri'        => 'https://creativecommons.org/licenses/by-nc-sa/2.0/',
            'dc:title'       => 'Creative Commons BY-NC-SA 2.0',
            'dc:description' => 'license_ref'
          }
          post @path, body.to_json, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @license = @work.license_refs.first
          @id = FedoraID.shorten(@license.id)
        end

        it 'increases number of license references' do
          expect(@work.license_refs.count).to be 1
          expect(@work.license_refs.first.title).to be @license.title
        end

        it 'return current location header' do
          expect_header('Location', "/work/#{@work_id}##{@id}")
        end

        describe 'response body' do
          it 'contains @id' do
            expect(response.body).to include("\"@id\":\"#{work_license_url(work_id: @work_id, id: @id)}\"")
          end
          
          it 'contains title' do
            expect_json(:'dc:title' => @license.title)
          end
          
          it 'contains description' do
            expect_json(:'dc:description' => 'license_ref')
          end
        end

        it 'returns 404 if work_id is invalid' do
          post work_license_index_path(work_id: 'dlkfalsfjklkfds'), { format: :jsonld }
          expect_status :not_found
        end
      end
    end
  end

  describe 'PUT work/:work_id/license/:id' do
    include_context 'get work id'

    include_examples 'requires authentication and authorization' do
      let(:path) { @path }
      let(:action) { 'put' }
    end

    describe 'when authorized', authenticated: true, editor: true do
      include_examples 'throws error when fields missing' do
        let(:path) { @path }
        let(:action) { 'put' }
      end

      describe 'updates a new license' do
        include_examples 'successful request'

        before :context do
          body = {
            'ali:start_date' => '2011-11-01',
            'ali:end_date'   => '2012-11-01',
            'ali:uri'        => 'https://creativecommons.org/licenses/by-nc-sa/2.0/',
            'dc:title'       => 'Creative Commons',
            'dc:description' => 'license_ref'
          }
          put @path, body.to_json, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @work.reload
        end

        it 'updates title in fedora store' do
          expect(@work.license_refs.first.title).to eql 'Creative Commons'
        end

        describe 'response body' do
          it 'contains new title' do
            expect_json(:'dc:title' => 'Creative Commons')
          end
        end
      end
    end
  end

  describe 'DELETE work/:work_id/license/:id' do
    include_context 'get work id'

    include_examples 'requires authentication and authorization' do
      let(:path) { @path }
      let(:action) { 'delete' }
    end

    describe 'when authorized', authenticated: true, editor: true do
      describe 'succesfully deletes license' do
        include_examples 'successful request'

        before :context do
          delete @path, {}, {
            'ACCEPT'       => 'application/ld+json',
            'CONTENT_TYPE' => 'application/ld+json'
          }
          @work.reload
        end
        
        it 'response body contains success' do
          expect_json(:status => "success")
        end
        
        it 'account is deleted from fedora store' do
          expect(@work.license_refs.count).to eq 0
        end
      end
    end
  end
end
