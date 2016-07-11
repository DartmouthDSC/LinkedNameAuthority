require 'rails_helper'

RSpec.describe Oracle::Organization, type: :model do
  describe 'querying Oracle locally', oracle: true do
    it 'can query for first row' do
      expect(Oracle::Organization.first).not_to be nil
    end

    describe '.type' do
      it 'returns at least one result for each type' do
        Oracle::Organization::ORDERED_ORG_TYPES.each do |t|
          expect(Oracle::Organization.type(t).count).to be > 1
        end
      end
    end

    describe '.modified_since' do
      it 'does not limit query if date is nil' do
        query = Oracle::Organization.modified_since(nil)
        expect(query.where_values).to eq []
        expect(query.where_values_hash).to eql({})
        expect(query.count).to eq Oracle::Organization.count
      end

      it 'accepts Date, Time and DateTime objects' do
        num_results = Oracle::Organization.modified_since(Date.today - 10.years).count
        expect(num_results).to be > 1
        expect(Oracle::Organization.modified_since(Time.now - 10.years).count).to eq num_results
        expect(Oracle::Organization.modified_since(DateTime.now - 10.years).count).to eq num_results
      end
            
      it 'returns correct number of results' do
        expect(
          Oracle::Organization.modified_since(Time.now - 100.years).count
        ).to eql Oracle::Organization.count
      end
    end

    describe '.ended' do
      it 'returns at least one organization' do
        expect(Oracle::Organization.ended.count).to be > 1
      end

      it 'returns pension department' do
        results = Oracle::Organization.ended.where(organization: "Pension")
        expect(results.count).to eq 1
        expect(results.first.organization_id).to eq 5744
      end
    end
  end
end
