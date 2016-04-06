require 'rails_helper'

RSpec.describe Load::Loader do
  before :context do
    @cached_error_notices = ENV['LOADER_ERROR_NOTICES']
    ENV['LOADER_ERROR_NOTICES'] = 'me@example.com'
    @loader = Load::Loader.new('Test Loader')
  end

  after :context do
    ENV['LOADER_ERROR_NOTICES'] = @cached_error_notices
  end
  
  subject { @loader }

  describe '#add_to_import_table' do
    before :context do
      Import.destroy_all
      @loader.add_to_import_table
    end
    
    it 'adds row to table' do
      expect(Import.count).to eq 1
    end

    describe 'row' do
      subject { Import.first }
      its(:status) { is_expected.to eq '0 errors' }
      its(:load) { is_expected.to eq 'Test Loader' }
      its(:time_started) { is_expected.to be_within(5).of Time.now }
    end
  end

  describe '#log_warning' do
    it 'adds to hash' do
      subject.log_warning('TEST WARNING', 'about no one')
      hash = { 'TEST WARNING' => ['about no one'] }
      expect(subject.warnings).to eq hash
    end
  end

  describe '#log_error' do
    it 'adds to hash' do
      subject.log_error(ArgumentError.new('missing lots of variables'), 'testing error')
      hash =  { 'missing lots of variables' => ['testing error'] }
      expect(subject.errors).to eq hash
    end

    it 'raises exception if throws_error is true' #maybe
  end

  describe '#send_email'
  

  describe '#find_organization' do
    before :context do
      @library = FactoryGirl.create(:library, alt_label: ['Library', 'LIB', 'DLC'])
    end
    
    it 'returns organization if super organization matches' do
      hash = {
        label: 'Dartmouth College Library',
        alt_label: ['LIB'],
        super_organization_id: @library.super_organizations.first.id
      }
      expect(subject.instance_eval{ find_organization(hash) }).to eq @library
    end
    
    context 'returns nil' do 
      it 'when  organization was not found' do
        expect(subject.instance_eval{ find_organization({ label: 'The Best Library'}) }).to be nil
      end
      
      it 'when super organization id not valid' do
        hash = {
          label: 'Dartmouth College Library',
          alt_label: ['LIB'],
          super_organization_id: 'not-a-valid-id'
        }
        expect(subject.instance_eval{ find_organization(hash) }).to be nil
      end
      
      it 'when super organization id does not match' do
        hash = {
          label: 'Dartmouth College Library',
          alt_label: ['LIB'],
          super_organization_id: @library.sub_organizations.first.id
        }
        expect(subject.instance_eval{ find_organization(hash) }).to be nil
      end
    end

    context 'returns organization if found' do
      it 'by alt_label' do
        expect(subject.instance_eval{
                 find_organization({ alt_label: ['Library']})
               }).to eq @library
      end
      
      it 'by label' do
        expect(subject.instance_eval{
                 find_organization({ label: 'Dartmouth College Library' })
               }).to eq @library
      end
      
      it 'by begin date' do
        expect(subject.instance_eval{
                 find_organization({ begin_date: '1974-01-01' })
               }).to eq @library
      end
    end

    describe 'throws error' do
      it 'when more than one matching organization was found' do
        lib = FactoryGirl.create(:library)
        expect {
          subject.instance_eval{ find_organization({ label: 'Dartmouth College Library' }) }
        }.to raise_error ArgumentError
        lib.destroy
      end

      it 'when hash is empty' do
        expect {
          subject.instance_eval { find_organization({}) }
        }.to raise_error ArgumentError
      end
          
      it 'when only super organization id is provided' do
        expect {
          subject.instance_eval { find_organization({ super_organization_id: 'blah' }) }
        }.to raise_error ArgumentError
      end

      it 'when an invalid key is passed in' do
        expect {
          subject.instance_eval { find_organization({ super_id: '123' }) }
        }.to raise_error ArgumentError
      end
    end
  end

  describe '#find_organization!' do
    it 'throws errors if organization could not be found' do
      expect {
        subject.instance_eval{ find_organization!({ label: 'The Unicorn Society' }) }
      }.to raise_error Load::ObjectNotFoundError
    end
  end

  describe '#find_person_by_netid' do
    before :example do
      Lna::Account.destroy_all
    end
    
    it 'returns nil if no person is found' do
      expect(subject.instance_eval{ find_person_by_netid('d0000a')}).to be nil
    end

    it 'returns correct person' do
      acnt = FactoryGirl.create(:netid)
      expect(subject.instance_eval{
               find_person_by_netid(acnt.account_name)
             }).to eq acnt.account_holder
    end

    it 'throws error when account holder is an org' do
      acnt = FactoryGirl.create(:netid, account_holder: FactoryGirl.create(:thayer))
      expect {
        subject.instance_eval { find_person_by_netid(acnt.account_name) }
      }.to raise_error RuntimeError
    end
    
    
    it 'throws error when missing netid' do
      expect { subject.instance_eval{ find_person_by_netid } }.to raise_error ArgumentError
    end
  end

  describe '#find_dart_account' do
    before :example do
      Lna::Account.destroy_all
    end
    
    it 'returns nil if no dart account found' do
      expect(subject.instance_eval{ find_dart_account('d0000a') }).to be nil
    end
    
    it 'returns correct dart account' do
      FactoryGirl.create(:netid, account_name: 'd99999a')
      dart = FactoryGirl.create(:netid)
      expect(subject.instance_eval{ find_dart_account(dart.account_name) }).to eq dart
    end

    it 'throws error when more than one dart account matches' do
      FactoryGirl.create(:netid)
      dart = FactoryGirl.create(:netid)
      expect {
        subject.instance_eval{ find_dart_account(dart.account_name) }
      }.to raise_error ArgumentError
    end
    
    it 'throws error when missing netid' do
      expect { subject.instance_eval{ find_dart_account } }.to raise_error ArgumentError
    end
  end
end
