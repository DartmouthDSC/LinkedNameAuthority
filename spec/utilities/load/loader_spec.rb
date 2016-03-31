require 'rails_helper'

RSpec.describe Load::Loader do
  before :context do
    ENV['LOADER_ERROR_NOTICES'] = 'me@example.com'
    @loader = Load::Loader.new('Test Loader', throw_errors: true)
  end

  after :context do
    # reset environmental variable
  end
  
  subject { @loader }

  describe '#find_organization' do
    before :context do
      @library = FactoryGirl.create(:library, alt_label: ['Library', 'LIB', 'DLC'])
    end
    
    it 'returns nil if organization was not found' do
      expect(subject.instance_eval{ find_organization({ label: 'The Best Library'}) }).to be nil
    end

    describe 'returns organization if found' do
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

    it 'throws error if more than one matching organization was found.' do
      lib = FactoryGirl.create(:library)
      expect {
        subject.instance_eval{ find_organization({ label: 'Dartmouth College Library' }) }
      }.to raise_error ArgumentError
      lib.destroy
    end
  end

  describe '#find_organization!' do
    it 'throws errors if organization could not be found' do
      expect {
        subject.instance_eval{ find_organization!({ label: 'The Unicorn Society' }) }
      }.to raise_error ArgumentError
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
