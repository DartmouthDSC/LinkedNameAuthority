require 'rails_helper'

RSpec.describe Oracle::Employee, type: :model do
  describe 'querying Oracle locally', oracle: true do 
    # Scott Drysdale
    let(:test_netid_as)    { 'd19125j' }
    let(:test_surname_as)  { 'Drysdale' }
    
    # Tom Trimarco
    let(:test_netid_gsm)   { 'd83637s' }
    let(:test_surname_gsm) { 'Trimarco' }
    
    it 'can query for first row' do
      expect { Oracle::Employee.first }.not_to raise_error
      expect(Oracle::Employee.first).not_to be nil
    end
        
    it 'has an A+S row we know about' do
      expect(Oracle::Employee.find_by(netid: test_netid_as).last_name).to eql(test_surname_as)
    end
    
    it 'has a GSM row we know about' do
      expect(Oracle::Employee.find_by(netid: test_netid_gsm).last_name).to eql(test_surname_gsm)
    end

    describe '.primary' do
      it 'has at least one matching row' do 
        expect(Oracle::Employee.primary.count).to be > 1
      end
    end
    
    describe '.not_primary' do
      it 'has at least one matching row' do
        expect(Oracle::Employee.not_primary.count).to be > 1
      end
    end

    describe '.valid_title' do
      it 'has at least one matching row' do
        expect(Oracle::Employee.valid_title.count).to be > 1
      end
    end
  end

  describe '.primary' do
    it 'contains correct query' do
      expect(Oracle::Employee.primary.where_values_hash).to eql({'primary_flag' => ["Y", "y"]})
    end
  end
end
