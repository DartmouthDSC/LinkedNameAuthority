require 'fedora_id'

# Request returns status code of 201
RSpec.shared_examples 'successful POST request' do
  it 'returns 201 status code' do
    expect(response).to have_http_status(:created)
  end
end

# Request returns status code of 200
RSpec.shared_examples 'successful request' do
  it 'returns 200 status code' do
    expect(response).to be_success
  end

  it 'returns content type of application/ld+json' do
    expect(response.content_type).to eq 'application/ld+json'
  end
end


RSpec.shared_examples 'requires authentication and authorization' do  
  describe 'when not authenticated' do
    it 'returns 401 status code' do
      send action, path, { format: :jsonld }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'when not authorized', authenticated: true do
    it 'returns 403 status code' do
      send action, path, { format: :jsonld }
      expect(response).to have_http_status(:forbidden)
    end
  end
end


# Creates person to test with. Deletes person when done.
RSpec.shared_context 'creates test person' do
  before :all do
    @jane = FactoryGirl.create(:jane)
    @person_id = FedoraID.shorten(@jane.id)
  end
end

RSpec.shared_context 'throws error when fields missing' do
  describe 'when missing required fields' do
    it 'returns status code of 422' do
      send action, path, '{}', {
             "ACCEPT"       => 'application/ld+json',
             "CONTENT_TYPE" => 'application/ld+json'
           }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
