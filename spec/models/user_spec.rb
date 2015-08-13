require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has valid factory' do
    jane = FactoryGirl.create(:user)
    expect(jane).to be_truthy
  end

  it 'requires provider' do
    expect{ FactoryGirl.create(:user, provider: '') }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'requires netid' do
    expect{ FactoryGirl.create(:user, netid: '') }.to raise_error ActiveRecord::RecordInvalid
  end
  
  it 'requires realm' do
    expect{ FactoryGirl.create(:user, realm: '') }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'requires name' do
    expect{ FactoryGirl.create(:user, name: '') }.to raise_error ActiveRecord::RecordInvalid
  end

  describe 'validates unique attributes' do
    before :each do
      FactoryGirl.create(:user)
    end
    
    it 'requires unique uid' do
       expect{ FactoryGirl.create(:user, netid: 'd12345d') }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'requires unique netid' do
      expect{ FactoryGirl.create(:user, uid: 'd12345d@dartmouth.edu') }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '.from_omniauth', :omniauth do
    before :all do
      @jane = User.from_omniauth(FactoryGirl.create(:omniauth_hash))
    end
    
    it 'creates user record' do
      expect(@jane).to be_instance_of(User)
    end

    it 'extracts realm correctly' do
      expect(@jane.realm).to eql('dartmouth.edu')
    end

    it 'creates a correct uid' do
      expect(@jane.uid).to eql('f12345f@dartmouth.edu')
    end
     
    context 'when user logs in for the second time' do
      before :all do
        @jane = User.from_omniauth(
          FactoryGirl.create( :omniauth_hash,
                              affil: 'THAY',
                              user: 'Jane A. Doe-Smith@THAYER.DARTMOUTH.EDU',
                              name: 'Jane A. Doe-Smith', ))
      end
      
      it 'updates realm' do
        expect(@jane.realm).to eql('thayer.dartmouth.edu')
      end

      it 'updates name' do
        expect(@jane.affil).to eql('THAY')
      end

      it 'updates affiliation' do
        expect(@jane.name).to eql('Jane A. Doe-Smith')
      end

      it 'updates uid' do
        expect(@jane.uid).to eql('f12345f@thayer.dartmouth.edu')
      end
    end

    after :all do
      @jane.destroy
    end
  end
  
end
