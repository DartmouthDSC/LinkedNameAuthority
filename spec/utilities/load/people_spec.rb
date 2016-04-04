require 'rails_helper'

RSpec.describe Load::People do
  before :context do
    @cached_error_notices = ENV['LOADER_ERROR_NOTICES']
    ENV['LOADER_ERROR_NOTICES'] = 'me@example.com'

    FactoryGirl.create(:thayer)
    FactoryGirl.create(:thayer, label: 'Computer Science', hr_id: '5678')
    @load = Load::People.new("People from Test Data", throw_errors: true) #use let?
  end

  after :context do
    ENV['LOADER_ERROR_NOTICES'] = @cached_error_notices
  end
  
  describe '#into_lna' do
    context 'creates new person' do 
      before :context do
        @hash = FactoryGirl.create(:person_hash)
        @person = @load.into_lna(@hash)
      end
    
      after :context do
        @person.destroy # Destroy person and any attached objects.
      end
      
      subject { @person }
      
      it { is_expected.to be_an_instance_of Lna::Person }

      its(:full_name)   { is_expected.to eq @hash[:person][:full_name] }
      its(:given_name)  { is_expected.to eq @hash[:person][:given_name] }
      its(:family_name) { is_expected.to eq @hash[:person][:family_name] }
      
      it 'sets account with netid' do
        acct = Lna::Account.where(title: 'Dartmouth',
                                  account_name: @hash[:netid]).first
        expect(subject.accounts).to include(acct)
      end

      it 'sets primary organization' do
        expect(subject.primary_org.hr_id).to eql @hash[:membership][:org][:hr_id]
        expect(subject.primary_org.label).to eql @hash[:membership][:org][:label]
      end
      
      it 'sets membership with title' do
        mems = subject.memberships.to_a.select do |m|
          m.title == @hash[:membership][:title]
          m.organization.hr_id == @hash[:membership][:org][:hr_id]
          m.organization.label == @hash[:membership][:org][:label]
        end
        expect(mems.count).to be 1
      end
      
      it 'sets membership organization' do
        expect(subject.memberships.first.organization.hr_id).to eql @hash[:membership][:org][:hr_id]
      end
    end

    context 'changes to a person\'s infomation' do
      before :example do
        @original = @load.into_lna(FactoryGirl.create(:person_hash))
      end

      after :example do
        @original.destroy
      end
      
      it 'updates full name' do
        p = { full_name: 'Jane Doe' }
        updated = @load.into_lna(FactoryGirl.create(:person_hash, person: p))
        expect(updated.id).to eql @original.id
        expect(updated.full_name).to eql p[:full_name]
      end
    end

    context 'adding new primary membership' do
      before :context do
        @original = @load.into_lna(FactoryGirl.create(:person_hash))
        m = { primary: true,
              title: 'Associate Professor',
              org: { label: 'Computer Science',
                     hr_id: '5678'  }            }
        @updated = @load.into_lna(FactoryGirl.create(:person_hash, membership: m))
        @updated.reload
      end

      after :context do
        @updated.destroy
      end

      subject { @updated }
      
      it 'updates correct person' do
        expect(subject.id).to eql @original.id
      end

      it 'updates primary org' do
        expect(subject.primary_org.hr_id).to eql '5678'
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
        @load.into_lna(FactoryGirl.create(:person_hash))
        m = { title: 'Associate Professor',
              org: { label: 'Computer Science',
                     hr_id: '5678' }              }
        @updated = @load.into_lna(FactoryGirl.create(:person_hash, membership: m))
        @updated.reload
      end

      after :context do
        @updated.destroy
      end

      subject { @updated }
      
      it 'increases number of membership' do
        expect(subject.memberships.count).to eql 2
      end

      it 'creates new membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Associate Professor' }
        expect(m.count).to eql 1
      end

      it 'sets correct organization for membership' do
        m = subject.memberships.to_a.select { |x| x.title == 'Associate Professor' }
        expect(m.first.organization.hr_id).to eql '5678'
      end
        
      it 'does not change the primary organization' do
        expect(subject.primary_org.hr_id).to_not eql '5678'
      end
      
      it 'uses existing organization for membership' do
        m = { title: 'Department Chair',
              org: { label: 'Thayer School of Engineering',
                     hr_id: '1234' }                        }
        @load.into_lna(FactoryGirl.create(:person_hash, membership: m))
        subject.reload
        mem = subject.memberships.map { |x| x.organization.id }
        expect(mem.count).to eql 3
        expect(mem.uniq.count).to eql 2
      end
    end

    context 'updating memberships' do
      before :context do
        @load.into_lna(FactoryGirl.create(:person_hash))
        hash = FactoryGirl.create(:person_hash)
        hash[:membership][:email] = 'jane.doe@dartmouth.edu'
        @updated = @load.into_lna(hash)
      end
      
      after :context do
        @updated.destroy
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
        hash = FactoryGirl.create(:person_hash, netid: nil)
        expect { @load.into_lna(hash) }.to raise_error NotImplementedError
      end
      
      it 'new person is added without primary membership' do
        m = { title: 'Professor', org: { label: 'Anthropology', code: 'ANTH' } }
        hash = FactoryGirl.create(:person_hash, membership: m)
        expect { @load.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'new person is added without person hash' do
        hash = FactoryGirl.create(:person_hash, person: nil)
        expect { @load.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'there is no membership or person' do
        hash = FactoryGirl.create(:person_hash, membership: nil, person: nil)
        expect { @load.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'membership does not have a org' do
        hash = FactoryGirl.create(:person_hash, membership: { title: 'Professor' })
        expect { @load.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'org does not have a label' do
        hash = FactoryGirl.create(:person_hash)
        hash[:membership][:org][:label] = nil
        expect { @load.into_lna(hash) }.to raise_error ArgumentError
      end

      it 'person does not have a name' do
        hash = FactoryGirl.create(:person_hash)
        hash[:person][:full_name] = nil
        expect { @load.into_lna(hash) }.to raise_error ActiveFedora::RecordInvalid
      end
    end
  end
end
