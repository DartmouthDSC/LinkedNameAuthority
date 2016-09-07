require 'rails_helper'

RSpec.describe Import, type: :model do
  describe '.last_successful_import' do
    it 'returns nil if Import table empty' do
      expect(Import.last_successful_import('Bunnies')).to be nil
    end
    
    it 'returns nil if there are no imports for load' do
      FactoryGirl.create(:org_import)
      expect(Import.last_successful_import('Bunnies')).to be nil
    end
    
    it 'returns correct import time when multiple entries' do
      result = FactoryGirl.create(:people_import)
      FactoryGirl.create(:people_import, time_started: DateTime.now - 2.hours)
      FactoryGirl.create(:org_import, time_started: DateTime.now + 2.hours)
      expect(Import.last_successful_import('People from Test').to_i).to eql result.time_started.to_i
    end

    it 'returns correct import time when unsuccessful entries' do
      result = FactoryGirl.create(:people_import)
      FactoryGirl.create(:people_import, time_started: DateTime.now + 2.hours, success: false)
      expect(Import.last_successful_import('People from Test').to_i).to eq result.time_started.to_i
    end
  end

  describe 'validations' do
    it 'requires load name' do
      expect {
        FactoryGirl.create(:people_import, load: nil)
      }.to raise_error ActiveRecord::RecordInvalid
    end
    
    it 'requires time_started' do
      expect {
        FactoryGirl.create(:people_import, time_started: nil)
      }.to raise_error ActiveRecord::RecordInvalid
    end
    
    it 'requires time_ended' do
      expect {
        FactoryGirl.create(:people_import, time_ended: nil)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
