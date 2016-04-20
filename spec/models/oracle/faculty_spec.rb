require 'rails_helper'

RSpec.describe Oracle::Faculty, type: :model, oracle: true do

# Scott Drysdale
  let(:testNetidAS)    { 'd19125j'.upcase }
  let(:testSurnameAS)  { 'Drysdale' }

# Tom Trimarco
  let(:testNetidGSM)   { 'd83637s'.upcase }
  let(:testSurnameGSM) { 'Trimarco' }

  it 'does not throw an error' do
    expect { Oracle::Faculty.count(:distinct => true) }.not_to raise_error
  end

  it 'has one or more rows' do
    rowCount = Oracle::Faculty.count(:distinct => true)
    puts("Oracle::Faculty has #{rowCount} rows.")
    expect(rowCount).to be > 0
  end

  it 'has an A+S row we know about' do
####    puts("Oracle::Faculty has the following methods:\n\t",
####         Oracle::Faculty.methods.sort.join("\n\t").to_s)
    puts(Oracle::Faculty.find_by(username: testNetidAS).email)
    expect(Oracle::Faculty.find_by(username: testNetidAS).lastname).to eql(testSurnameAS)
  end

  it 'has a GSM row we know about' do
    puts(Oracle::Faculty.find_by(username: testNetidGSM).email)
    expect(Oracle::Faculty.find_by(username: testNetidGSM).lastname).to eql(testSurnameGSM)
  end

end
