require 'rails_helper'

RSpec.describe Lna::Organization::ChangeEvent, type: :model do
  it 'has a valid factory' do
    code_change = FactoryGirl.create(:code_change)
    expect(code_change).to be_truthy
    code_change.resulting_organizations.destroy_all
    code_change.original_organizations.destroy_all
    code_change.destroy
  end

  context '.create' do
    before :context do
      @code_change = FactoryGirl.create(:code_change)
    end

    after :context do
      @code_change.resulting_organizations.destroy_all
      @code_change.original_organizations.destroy_all
      @code_change.destroy
    end
    
    subject { @code_change }

    it { is_expected.to be_instance_of Lna::Organization::ChangeEvent }
    it { is_expected.to be_an ActiveFedora::Base }
    
    it 'sets time' do
      expect(subject.at_time).to be_instance_of Date
      expect(subject.at_time.to_s).to eql '2000-01-01'
    end
    
    it 'sets description' do
      expect(subject.description).to eql 'Organization code change.'
    end
  end

  context '#original_organizations' do
    before :context do
      @code_change = FactoryGirl.create(:code_change)
    end

    after :context do
      @code_change.resulting_organizations.destroy_all
      @code_change.original_organizations.destroy_all
      @code_change.destroy
    end
    
    subject { @code_change }
    
    it 'has original organizations' do  
      expect(subject.original_organizations.count).to eql 1
    end

    it 'original organization is historic' do
      expect(subject.original_organizations.first).to be_instance_of Lna::Organization::Historic
    end
  end

  context '#resulting_organizations' do    
    before :context do
      @code_change = FactoryGirl.create(:code_change)
      @code_change.reload
    end

    after :context do
      @code_change.resulting_organizations.destroy_all
      @code_change.original_organizations.destroy_all
      @code_change.destroy
    end
    
    subject { @code_change }
    
    it 'has one resulting organizations' do
      expect(subject.resulting_organizations.count).to eql 1
    end
    
    it 'can have multiple resulting organization' do
      new = FactoryGirl.create(:old_thayer, resulted_from: subject)
      subject.reload
      expect(subject.resulting_organizations.count).to eql 2
    end
    
    it 'resulting organization can be active' do
      class_names = subject.resulting_organizations.map { |r| r.class }
      expect(class_names).to include Lna::Organization
    end
    
    it 'resulting organization can be historic' do
      class_names = subject.resulting_organizations.map { |r| r.class }
      expect(class_names).to include Lna::Organization::Historic
    end
  end
  
  context 'validations' do
    before :example do
      @code_change = FactoryGirl.create(:code_change)
    end

    after :example do
      @code_change.resulting_organizations.destroy_all
      @code_change.original_organizations.destroy_all
      @code_change.destroy
    end
    
    subject { @code_change }

    it 'assures time is set' do
      subject.at_time = nil
      expect(subject.save).to be false
    end

    it 'assured description is set' do
      subject.description = nil
      expect(subject.save).to be false
    end
    
    it 'assures that there is only one original organization' do
      subject.original_organizations << FactoryGirl.create(:old_thayer)
      expect(subject.save).to be false
    end

    it 'assures original organization is historic' do
      new = FactoryGirl.create(:thayer)
      expect { subject.original_organizations << new }.to raise_error ActiveFedora::AssociationTypeMismatch
      new.destroy
    end
    
    it 'assures there is at least one resulting organization' do
      subject.resulting_organizations.destroy_all
      expect(subject.save).to be false
    end
  end
end
