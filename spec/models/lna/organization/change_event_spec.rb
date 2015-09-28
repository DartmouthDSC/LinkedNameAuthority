require 'rails_helper'

RSpec.describe Lna::Organization::ChangeEvent, type: :model do
  it 'has a valid factory' do
    code_change = FactoryGirl.create(:code_change)
    expect(code_change).to be_truthy
#    code_change.destroy # have to destroy_resulting and original organization
  end

  context '.create' do
    before :context do
      @code_change = FactoryGirl.create(:code_change)
    end

    after :context do
 #     @code_change.destroy
      # have to destroy resulting and original_organization
    end
    
    subject { @code_change }

    it { is_expected.to be_instance_of Lna::Organization::ChangeEvent }
    it { is_expected.to be_an ActiveFedora::Base }
    
    it 'sets time'
    
    it 'sets description' do
      expect(subject.description).to eql 'Organization code change.'
    end
  end

  context '#original_organizations' do
    it 'has original organizations' do
      expect(subject.original_organizations.size).to eql 1
    end
  end

  context '#resulting_organizations' do
    it 'has a resulting organizations' do
      expect(subject.resulting_organizations.size).to eql 1
    end
    
    it 'can have multiple resulting organization'
    it 'resulting organization can be active'
    it 'resulting organization can be historic'
  end
  
  context 'validations' do
    it 'assures that there is only one original organization'

    it 'assures there is at least one resulting organization'

    it 'assures original organization is historic'
  end
end
