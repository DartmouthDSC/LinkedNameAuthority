require 'rails_helper'
require 'symplectic/elements/request'

RSpec.describe Symplectic::Elements::Request do
  describe '.get' do
    it 'raises error when modified since is not a DateTime object' do
      expect {
        Symplectic::Elements::Request.get('/users', modified_since: 'today')
      }.to raise_error Symplectic::Elements::RequestError
    end

    it 'raises error when api returns error' do
      stub_get_elements('/publication', query: { detail: 'ref', page: 1 })
        .to_return(status: 200, body: fixture('error.xml'), headers: {})

      expect {
        Symplectic::Elements::Request.get('publication')
      }.to raise_error Symplectic::Elements::ApiError
    end

    it 'raises error when status returned is not successful' do
      stub_get_elements('/publication', query: { detail: 'ref', page: 1 })
        .to_return(status: 404, body: fixture('error.xml'), headers: {})

      expect {
        Symplectic::Elements::Request.get('publication')
      }.to raise_error Symplectic::Elements::RequestError
    end

    it 'ignores page parameter if querying for all results' do
      stub_get_elements('/users', query: { detail: 'ref', page: 1})
        .to_return(status: 200, body: fixture('users-1.xml'), headers: {})

      stub_get_elements('/users', query: { detail: 'ref', page: 2})
        .to_return(status: 200, body: fixture('users-2.xml'), headers: {})

      Symplectic::Elements::Request.get('users', page: 2, all_results: true)
      
      expect(a_get_elements('/users', query: { detail: 'ref', page: 1 })).to have_been_made
      expect(a_get_elements('/users', query: { detail: 'ref', page: 2 })).to have_been_made
    end
  end
end
