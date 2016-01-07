require 'rails_helper'
require 'concerns/lna/license_behavior_spec'

RSpec.describe Lna::Collection::FreeToRead, type: :model do
  it 'has a valid factory' do
    open_access = FactoryGirl.create(:unrestricted_access)
    expect(open_access).to be_truthy
    expect(open_access).to be_instance_of Lna::Collection::FreeToRead
    person = open_access.document.collection.person
    org_id = person.primary_org.id
    person.destroy
    Lna::Organization.find(org_id).destroy
  end

  it_behaves_like 'license_behavior', :unrestricted_access
end
