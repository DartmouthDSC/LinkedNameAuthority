require 'rails_helper'

RSpec.describe Load::People do
  before :context do
    ENV["LOADER_ERROR_NOTICES"] = "me@example.com"
    FactoryGirl.create(:thayer)
    @load = Load::People.new('People from Test Data', throw_errors: true)
  end

  after :context do
    ENV["LOADER_ERROR_NOTICES"] = nil
  end
  
  describe '#into_lna' do
    context 'creates new person' do 
      before :context do
        @hash = FactoryGirl.create(:lna_hash)
        @person = @load.into_lna(@hash)
      end
    
      after :context do
        id = @person.primary_org.id
        @person.destroy # Destroy person and any attached objects.
        Lna::Organization.find(id).destroy
      end
      
      subject { @person }
      
      it { is_expected.to be_an_instance_of Lna::Person }
      
      it 'sets full name' do
        expect(subject.full_name).to eql @hash[:person][:full_name]
      end

      it 'sets given name' do
        expect(subject.given_name).to eql @hash[:person][:given_name]
      end

      it 'sets family name' do
        expect(subject.family_name).to eql @hash[:person][:family_name]
      end
        
      it 'sets account with netid' do
        acct = Lna::Account.where(title: 'Dartmouth',
                                  account_name: @hash[:netid]).first
        expect(subject.accounts).to include(acct)
      end

      it 'sets primary organization' do
        expect(subject.primary_org.code).to eql @hash[:membership][:org][:code]
        expect(subject.primary_org.label).to eql @hash[:membership][:org][:label]
      end
      
      it 'sets membership with title' do
        mems = subject.memberships.to_a.select do |m|
          m.title == @hash[:membership][:title]
          m.organization.code == @hash[:membership][:org][:code]
          m.organization.label == @hash[:membership][:org][:label]
        end
        expect(mems.count).to be 1
      end
      
      it 'sets membership organization' do
        expect(subject.memberships.first.organization.code).to eql @hash[:membership][:org][:code]
      end
    end

    context 'changes to a person\'s infomation' do
      before :example do
        @original = @load.into_lna(FactoryGirl.create(:lna_hash))
      end

      after :example do
        id = @original.primary_org.id
        @original.destroy
        Lna::Organization.find(id).destroy
      end
      
      it 'updates full name' do
        p = { full_name: 'Jane A. Doe' }
        updated = @import.into_lna(FactoryGirl.create(:lna_hash, person: p))
        expect(updated.id).to eql @original.id
        expect(updated.full_name).to eql p[:full_name]
      end
    end

    context 'adding new primary membership' do
      before :context do
        @original = @import.into_lna(FactoryGirl.create(:lna_hash))
        m = { primary: true,
              title: 'Associate Professor',
              org: { label: 'Computer Science',
                     code: 'COSC'  }            }
        @updated = @import.into_lna(FactoryGirl.create(:lna_hash, membership: m))
        @updated.reload
      end

      after :context do
        ids = @updated.memberships.map { |x| x.organization.id }
        @updated.destroy
        ids.each { |i| Lna::Organization.find(i).destroy }
      end

      subject { @updated }
      
      it 'updates correct person' do
        expect(subject.id).to eql @original.id
      end

      it 'updates primary org' do
        expect(subject.primary_org.code).to eql 'COSC'
      end
      
      it 'number of memberships increased' do
        expect(subject.memberships.count).to eql 2
      end

      it 'adds new membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Associate Professor' }
        expect(m.count).to eql 1
      end
      
      it 'keeps previous membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Professor' }
        expect(m.count).to eql 1
      end
    end
   
    context 'adding new membership' do
      before :context do
        @import.into_lna(FactoryGirl.create(:lna_hash))
        m = { title: 'Associate Professor',
              org: { label: 'Computer Science',
                     code: 'COSC' }              }
        @updated = @import.into_lna(FactoryGirl.create(:lna_hash, membership: m))
        @updated.reload
      end

      after :context do
        ids = @updated.memberships.map { |x| x.organization.id }
        @updated.destroy
        ids.uniq.each { |i| Lna::Organization.find(i).destroy }
      end

      subject { @updated }
      
      it 'increases number of membership' do
        expect(subject.memberships.count).to eql 2
      end

      it 'creates new membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Associate Professor' }
        expect(m.count).to eql 1
      end

      it 'creates new organization for membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Associate Professor' }
        expect(m.first.organization.code).to eql 'COSC'
      end
        
      it 'does not change the primary organization' do
        expect(subject.primary_org.code).to_not eql 'COSC'
      end
      
      it 'uses existing organization for membership' do
        m = { title: 'Department Chair',
              org: { label: 'Thayer School of Engineering',
                     code: 'THAY' }                        }
        @import.into_lna(FactoryGirl.create(:lna_hash, membership: m))
        subject.reload
        mem = subject.memberships.map { |x| x.organization.id }
        expect(mem.count).to eql 3
        expect(mem.uniq.count).to eql 2
      end
    end

    context 'updating memberships' do
      before :context do
        @import.into_lna(FactoryGirl.create(:lna_hash))
        hash = FactoryGirl.create(:lna_hash)
        hash[:membership][:email] = 'jane.doe@dartmouth.edu'
        @updated = @import.into_lna(hash)
      end
      
      after :context do
        id = @updated.primary_org.id
        @updated.destroy
        Lna::Organization.find(id).destroy
      end

      subject { @updated }

      it 'does not add a new membership' do
        expect(subject.memberships.count).to eql 1
      end
      
      it 'updates email' do
        expect(subject.memberships.first.email).to eql 'jane.doe@dartmouth.edu'
      end
    end
    
    context 'throws errors when' do
      it 'netid is missing' do
        hash = FactoryGirl.create(:lna_hash, netid: nil)
        expect { @import.into_lna(hash) }.to raise_error NotImplementedError
      end
      
      it 'new person is added without primary membership' do
        m = { title: 'Professor', org: { label: 'Anthropology', code: 'ANTH' } }
        hash = FactoryGirl.create(:lna_hash, membership: m)
        expect { @import.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'new person is added without person hash' do
        hash = FactoryGirl.create(:lna_hash, person: nil)
        expect { @import.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'there is no membership or person' do
        hash = FactoryGirl.create(:lna_hash, membership: nil, person: nil)
        expect { @import.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'membership does not have a org' do
        hash = FactoryGirl.create(:lna_hash, membership: { title: 'Professor' })
        expect { @import.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'org does not have a label' do
        hash = FactoryGirl.create(:lna_hash)
        hash[:membership][:org][:label] = nil
        expect { @import.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'person does not have a name' do
        hash = FactoryGirl.create(:lna_hash)
        hash[:person][:full_name] = nil
        expect { @import.into_lna(hash) }.to raise_error ActiveFedora::RecordInvalid
      end
    end
  end
end
