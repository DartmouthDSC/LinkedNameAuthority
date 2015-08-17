require 'rails_helper'

RSpec.describe Import do

  describe '#to_lna' do
    
    before :context do
      @hash = FactoryGirl.create(:lna_hash)
      @person = Import.to_lna(@hash)
    end
    
    after :context do
      @person.destroy_all # Destroy person and any attached objects.
    end

    subject { @person }
    
    it { is_expected.to be_an_instance_of Lna::Person }

    it 'sets full name' do
      expect(subject.full_name).to eql @hash[:person][:full_name]
    end

    #it 'sets account with netid' do
    #  acct = Lna::Account.where(title: 'Dartmouth',
    #                            account_name: @hash[:netid]).first
    #  expect(subject.accounts).to include(acct)
    #end

    it 'sets membership with title'

    it 'sets membership organization with dept code'
    
  end
end
