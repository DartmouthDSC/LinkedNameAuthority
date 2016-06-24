require 'rails_helper'
require 'symplectic/elements/api'

RSpec.describe Symplectic::Elements::Api do
  describe '.new' do
    let(:api) { Symplectic::Elements::Api.new }
    
    subject { api }

    it { is_expected.to be_kind_of Faraday::Connection }

    its(:url_prefix) {
      is_expected.to eq URI('https://elements-api-dev.dartmouth.edu:9002/elements-secure-api')
    }

    it 'sets username' do
      expect(subject.config[:username]).to eq 'testperson'
    end

    it 'sets password' do
      expect(subject.config[:password]).to eq 'testpassword'
    end

    it 'sets api_root' do
      expect(subject.config[:api_root])
        .to eq 'https://elements-api-dev.dartmouth.edu:9002/elements-secure-api'
    end
    
    it 'sets basic authentication' do
      expect(subject.headers['Authorization']).to eq 'Basic dGVzdHBlcnNvbjp0ZXN0cGFzc3dvcmQ='
    end
  end  
end
