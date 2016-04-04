require 'rails_helper'

RSpec.describe Load::Organizations do
  before :context do
    @cached_error_notices = ENV['LOADER_ERROR_NOTICES']
    ENV['LOADER_ERROR_NOTICES'] = 'me@example.com'

    @provost = FactoryGirl.create(:provost)
    @president = FactoryGirl.create(:provost, label: 'Office of the President',
                                    alt_label: ['President'])
    @load = Load::Organizations.new('Organization from Test Data', throw_errors: true)
  end

  after :context do
    ENV['LOADER_ERROR_NOTICES'] = @cached_error_notices
  end

  describe '#into_lna'

  describe '#into_lna!' do
    context 'when a new active organization is created' do
      before :context do
        @hash = FactoryGirl.create(:org_hash)
        @org = @load.into_lna(@hash)
      end

      after :context do
        @org.destroy
      end
      
      subject { @org }

      its(:label)      { is_expected.to eq @hash[:label] }
      its(:alt_label)  { is_expected.to match_array @hash[:alt_label] }
      its(:hr_id)      { is_expected.to eq @hash[:hr_id] }
      its(:kind)       { is_expected.to eq @hash[:kind] }
      its(:hinman_box) { is_expected.to eq @hash[:hinman_box] }
      its(:begin_date) { is_expected.to eq Date.parse(@hash[:begin_date]) }
      
      it 'sets super organization' do
        expect(subject.super_organizations).to include @provost
      end
      
      it 'returns active organization' do
        expect(subject.active?).to be true
      end

      it 'returns same organization when added again' do
        expect(@load.into_lna(@hash)).to eq subject
      end
    end

    context 'when a new historic organization is created' do
      before :context do
        @hash = FactoryGirl.create(:org_hash, super_organization: nil, end_date: '31-12-2010')
        @org = @load.into_lna(@hash)
      end

      after :context do
        @org.destroy
      end

      subject { @org }

      its(:label)    { is_expected.to eq @hash[:label] }
      its(:hr_id)    { is_expected.to eq @hash[:hr_id] }
      its(:end_date) { is_expected.to eq Date.parse(@hash[:end_date]) }
      
      it 'returns a historic org' do
        expect(subject.historic?).to eq true
      end
    end

    
    context 'when an organization\'s label, alt_label, hb and super organization is updated' do
      before :context do
        @load.into_lna(FactoryGirl.create(:org_hash))
        @hash = FactoryGirl.create(:org_hash, label: 'Dartmouth College Library',
                                   alt_label: ['LIBR'], hinman_box: '6025',
                                   super_organization: { label: 'Office of the President' })
        @org = @load.into_lna(@hash)
        @org.reload
      end

      after :context do
        @org.destroy
      end

      subject { @org }
      
      it 'old label is moved to alt label' do
        expect(subject.alt_label).to include 'Library'
      end

      it 'adds to alt label if new alt labels are added' do
        expect(subject.alt_label).to include 'LIBR'
      end

      it 'does not delete current alt labels' do
        expect(subject.alt_label).to include 'DLC', 'LIB'
      end

      it 'replaces old super organization with new super organization' do
        expect(subject.super_organizations).to eq [@president]
      end

      it 'updates hinman box' do
        expect(subject.hinman_box).to eq @hash[:hinman_box]
      end

      it 'adds four warnings to warnings hash' do
        expect(@load.warnings.count).to eq 4
      end
    end

    context 'when an active organization\'s alt label and end date is updated' do
      before :context do
        @load.into_lna(FactoryGirl.create(:org_hash))
        hash = FactoryGirl.create(:org_hash, end_date: '31-12-2010', alt_label: ['Library'],
                                  super_organization: nil)
        @org = @load.into_lna(hash)
      end

      after :context do
        @org.destroy
      end

      subject { @org }
      
      it 'adds alt label' do
        expect(subject.alt_label).to include 'Library'
      end
      
      it 'returns a historic org' do
        expect(@org.historic?).to be true
      end
      
      it 'sets end date' do
        expect(@org.end_date).to eq Date.parse('31-12-2010')
      end
    end

    context 'when an organization is ended' do
      before :context do
        @load.into_lna(FactoryGirl.create(:org_hash))
        @org = @load.into_lna(FactoryGirl.create(:org_hash, end_date: '31-12-2010',
                                                 super_organization: nil))
        
      end

      after :context do
        @org.destroy
      end
      
      subject { @org }
      
      it 'converts to historic' do
        expect(@org.historic?).to be true
      end

      it 'sets end date' do
        expect(@org.end_date).to eq Date.parse('31-12-2010')
      end
    end

    context 'throws errors' do
      it 'when hash is missing label' do
        expect {
          @load.into_lna(FactoryGirl.create(:org_hash, label: nil))
        }.to raise_error ArgumentError
      end
      
      it 'when hash is missing information when creating new org' do
        expect {
          @load.into_lna(FactoryGirl.create(:org_hash, begin_date: nil))
        }.to raise_error ActiveFedora::RecordInvalid
      end
      
      it 'when super organization and end date are in hash' do
        expect {
          @load.into_lna(FactoryGirl.create(:org_hash, end_date: '31-12-2010'))
        }.to raise_error ArgumentError
      end
      
      it 'when super organization is not valid' do
        expect {
          @load.into_lna(FactoryGirl.create(:org_hash,
                                            super_organization: { label: 'Unicorn Academy' }))
        }.to raise_error Load::ObjectNotFoundError
      end
      
      it 'when hash keys are invalid' do # try to create organization with incorrect keys
        expect {
          @load.into_lna(FactoryGirl.create(:org_hash, rank: 'MAGICAL'))
        }.to raise_error ArgumentError
      end
    end
  end
end
