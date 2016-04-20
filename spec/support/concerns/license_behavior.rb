RSpec.shared_examples_for 'license_behavior' do |factory|
  before :context do
    @license = FactoryGirl.create(factory)
  end

  after :context do
    person = @license.document.collection.person
    org_id = person.primary_org.id
    person.destroy
    Lna::Organization.find(org_id).destroy
  end

  subject { @license }

  describe '.create' do
    it 'is a ActiveFedora::Base' do
      expect(subject).to be_an ActiveFedora::Base
    end

    it 'sets start_date' do
      expect(subject.start_date).to be_an_instance_of Date
    end

    it 'sets end_date' do
      expect(subject.end_date).to be_an_instance_of Date
    end

    it 'sets title' do
      expect(subject.title).not_to be nil
    end

    it 'sets document' do
      expect(subject.document).to be_an_instance_of Lna::Collection::Document
    end
  end

  describe '#document' do
    before :context do
      @article = FactoryGirl.create(:article, collection: @license.document.collection)
      @license.document = @article
    end
    
    it 'can change document' do
      expect(@license.document).to be @article
    end
  end

  describe 'validations' do
    after :example do
      subject.reload
    end

    it 'assures start_date is set' do
      subject.start_date = nil
      expect(subject.save).to be false
    end

    it 'assures title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end

    it 'assured document is set' do
      subject.document = nil
      expect(subject.save).to be false
    end

    it 'assures end_date is after start_date' do
      subject.start_date = subject.end_date + 1.day
      expect(subject.save).to be false
    end
  end
end
                                          
