require 'rails_helper'

RSpec.describe Load::Documents do
  before :all do
    @cached_error_notices = ENV['LOADER_ERROR_NOTICED']
    ENV['LOADER_ERROR_NOTICES'] = 'me@example.com'
  end

  after :all do
    ENV['LOADER_ERROR_NOTICES'] = @cached_error_notices
  end

  describe '#into_lna' do
    let(:load) { Load::Documents.new('Documents from Test Data') }
    
    it 'logs error when netid missing' do  
      load.into_lna(FactoryGirl.create(:doc_hash))
      expect(load.errors.count).to eq 1
    end
  end

  describe '#into_lna_by_netid!' do
    before :context do
      @person = FactoryGirl.create(:netid).account_holder
      @load = Load::Documents.new('Documents from Test Data')
    end
    
    describe 'when document does not exists' do
      before :context do
        @hash = FactoryGirl.create(:doc_hash)
        @doc = @load.into_lna_by_netid!('d00000a', @hash)
      end

      after :context do
        @doc.destroy
      end
      
      subject { @doc }

      it 'adds new document' do
        expect(Lna::Collection::Document.count).to eql 1
        expect(@person.collections.first.documents.count).to eq 1
      end

      describe 'sets document fields' do
        its(:author_list) { is_expected.to match_array @hash[:author_list] }
        its(:publisher)   { is_expected.to eq @hash[:publisher] }
        its(:date)        { is_expected.to eq Date.parse(@hash[:date]) }
        its(:title)       { is_expected.to eq @hash[:title] }
        its(:page_start)  { is_expected.to eq @hash[:page_start] }
        its(:page_end)    { is_expected.to eq @hash[:page_end] }
        its(:pages)       { is_expected.to eq @hash[:pages] }
        its(:volume)      { is_expected.to eq @hash[:volume] }
        its(:issue)       { is_expected.to eq @hash[:issue] }
        its(:number)      { is_expected.to eq @hash[:number] }
        its(:doi)         { is_expected.to eq @hash[:doi] }
        its(:abstract)    { is_expected.to eq @hash[:abstract] }
        its(:elements_id) { is_expected.to eq @hash[:elements_id] }
      end
      
      it 'adds warning for new document added' do
        expect(@load.warnings[Load::Documents::NEW_DOCUMENT].count).to eq 1
      end

      it 'adds document to correct person' do
        expect(@doc.collection).to eq @person.collections.first
      end
    end

    describe 'when document exists' do
      before :context do
        @doc = @load.into_lna_by_netid!('d00000a', FactoryGirl.create(:doc_hash))
      end

      after :context do
        @doc.destroy
      end

      subject { @load.into_lna_by_netid!('d00000a', FactoryGirl.create(:doc_hash)) }
      
      it 'does not create new document' do
        expect(Lna::Collection::Document.count).to eq 1
      end

      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
    
    it 'when netid invalid log warning' do # does not belong to a person currently in the lna
      @load.into_lna_by_netid!('d12345l', FactoryGirl.create(:doc_hash))
      expect(@load.warnings[Load::Documents::PERSON_RECORD_NOT_FOUND]).to include 'd12345l'
    end                          
                              
    describe 'throws error when' do 
      it 'required fields are missing' do
        hash = FactoryGirl.create(:doc_hash, title: nil)
        expect {
          @load.into_lna_by_netid!('d00000a', hash)
        }.to raise_error ActiveFedora::RecordInvalid
      end
      
      it 'document hash is missing' do
        expect {
          @load.into_lna_by_netid!('d00000a', nil)
        }.to raise_error ArgumentError
      end
    end
  end
end
