require 'rails_helper'
require 'concerns/lna/license_behavior_spec'

RSpec.describe Lna::Collection::LicenseReference, type: :model do
  it 'has a valid factory' do
    license = FactoryGirl.create(:license)
    expect(license).to be_truthy
    person = license.document.collection.person
    org_id = person.primary_org.id
    person.destroy
    Lna::Organization.find(org_id).destroy
  end

  it_behaves_like 'license_behavior', :license

  before :context do
    @license = FactoryGirl.create(:license)
  end

  after :context do
    person = @license.document.collection.person
    org_id = person.primary_org.id
    person.destroy
    Lna::Organization.find(org_id).destroy
  end

  subject { @license }
  
  context '.create' do    
    it 'sets license_uri' do
      expect(subject.license_uri).to eq 'https://creativecommons.org/licenses/by-nc-sa/3.0/'
    end
  end

  context 'validations' do
    it 'assures license_uri is set' do
      subject.license_uri = nil
      expect(subject.save).to be false
      subject.reload
    end
  end
end
