require 'rails_helper'

RSpec.describe Oracle::Employee, type: :model, oracle: true do
  # Scott Drysdale
  let(:test_netid_as)    { 'd19125j' }
  let(:test_surname_as)  { 'Drysdale' }

  # Tom Trimarco
  let(:test_netid_gsm)   { 'd83637s' }
  let(:test_surname_gsm) { 'Trimarco' }

  it 'does not throw an error' do
    expect { Oracle::Employee.count(distinct: true) }.not_to raise_error
  end

  it 'has one or more rows' do
    expect(Oracle::Employee.count(distinct: true)).to be > 0
  end

  it 'has an A+S row we know about' do
    expect(Oracle::Employee.find_by(netid: test_netid_as).last_name).to eql(test_surname_as)
  end

  it 'has a GSM row we know about' do
    expect(Oracle::Employee.find_by(netid: test_netid_gsm).last_name).to eql(test_surname_gsm)
  end
end
