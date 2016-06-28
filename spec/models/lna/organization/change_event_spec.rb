require 'rails_helper'

RSpec.describe Lna::Organization::ChangeEvent, type: :model do
  it 'has a valid factory' do
    hb_change = FactoryGirl.create(:hb_change)
    expect(hb_change).to be_truthy
    hb_change.resulting_organizations.destroy_all
    hb_change.original_organizations.destroy_all
    hb_change.destroy
  end

  context '.create' do
    before :context do
      @hb_change = FactoryGirl.create(:hb_change)
    end

    after :context do
      @hb_change.resulting_organizations.destroy_all
      @hb_change.original_organizations.destroy_all
      @hb_change.destroy
    end
    
    subject { @hb_change }

    it { is_expected.to be_instance_of Lna::Organization::ChangeEvent }
    it { is_expected.to be_an ActiveFedora::Base }
    
    it 'sets time' do
      expect(subject.at_time).to be_instance_of Date
      expect(subject.at_time.to_s).to eql '2000-01-01'
    end
    
    it 'sets description' do
      expect(subject.description).to eql 'Hinman box change.'
    end
  end

  context '#original_organizations' do
    before :context do
      @hb_change = FactoryGirl.create(:hb_change)
    end

    after :context do
      @hb_change.resulting_organizations.destroy_all
      @hb_change.original_organizations.destroy_all
      @hb_change.destroy
    end
    
    subject { @hb_change }
    
    it 'has original organizations' do  
      expect(subject.original_organizations.count).to eql 1
    end

    it 'original organization is historic' do
      expect(subject.original_organizations.first).to be_instance_of Lna::Organization::Historic
    end

    it 'can have multiple original organizations'
  end

  context '#resulting_organizations' do    
    before :context do
      @hb_change = FactoryGirl.create(:hb_change)
      @hb_change.reload
    end

    after :context do
      @hb_change.resulting_organizations.destroy_all
      @hb_change.original_organizations.destroy_all
      @hb_change.destroy
    end
    
    subject { @hb_change }
    
    it 'has one resulting organizations' do
      expect(subject.resulting_organizations.count).to eql 1
    end
    
    it 'can have multiple resulting organization' do
      new = FactoryGirl.create(:old_thayer, resulted_from: subject)
      subject.reload
      expect(subject.resulting_organizations.count).to eql 2
    end
    
    it 'resulting organization can be active' do
      class_names = subject.resulting_organizations.map { |r| r.class }
      expect(class_names).to include Lna::Organization
    end
    
    it 'resulting organization can be historic' do
      class_names = subject.resulting_organizations.map { |r| r.class }
      expect(class_names).to include Lna::Organization::Historic
    end
  end
  
  context 'validations' do
    before :example do
      @hb_change = FactoryGirl.create(:hb_change)
    end

    after :example do
      @hb_change.resulting_organizations.destroy_all
      @hb_change.original_organizations.destroy_all
      @hb_change.destroy
    end
    
    subject { @hb_change }

    it 'assures time is set' do
      subject.at_time = nil
      expect(subject.save).to be false
    end

    it 'assured description is set' do
      subject.description = nil
      expect(subject.save).to be false
    end
    
    it 'assures original organization is historic' do
      new = FactoryGirl.create(:thayer)
      expect { subject.original_organizations << new }.to raise_error ActiveFedora::AssociationTypeMismatch
      new.destroy
    end
    
    it 'assures there is at least one resulting organization' do
      subject.resulting_organizations.destroy_all
      expect(subject.save).to be false
    end
  end

  context '.trigger_event' do
    context 'when changing from one org to another' do 
      before :context do
        @thayer = FactoryGirl.create(:thayer)
        @old_thayer = FactoryGirl.create(:old_thayer)
        @change_event = Lna::Organization::ChangeEvent.trigger_event(
          @old_thayer, @thayer, description: 'HB change', date: Date.parse('2000-01-01')
        )
      end
      
      subject { @change_event }

      its(:description) { is_expected.to eq 'HB change' }
      its(:at_time)     { is_expected.to eq Date.parse('2000-01-01') }
      
      its(:resulting_organizations) { is_expected.to match_array [@thayer] }
      its(:original_organizations)  { is_expected.to match_array [@old_thayer] }
    end

    context 'when spliting an organization' do
      before :context do
        @its = FactoryGirl.create(:its)
        @new_library = Lna::Organization.create(label: 'Library', begin_date: Date.today,
                                                hr_id: '1234', kind: 'DIV')
        library = FactoryGirl.create(:library, label: 'Library and ITS')
        @jane = FactoryGirl.create(:jane, primary_org: library)
        @john = FactoryGirl.create(:jane, given_name: 'John', primary_org: library)
        @lib_admin = FactoryGirl.create(:thayer_prof, title: 'Head of Library', person: @jane,
                                   organization: library)
        @its_lib_admin = FactoryGirl.create(:thayer_prof, title: 'Head of ITS and Library',
                                            person: @jane, organization: library,
                                            begin_date: Date.today - 10, end_date: Date.yesterday)
        
        event = Lna::Organization::ChangeEvent.trigger_event(
          library, @new_library, description: 'Library and ITS split'
        )

        @library = event.original_organizations.first
        @change_event = Lna::Organization::ChangeEvent.trigger_event(@library, @its)
      end

      subject { @change_event }

      its(:description) { is_expected.to eq 'Library and ITS split' }
      its(:at_time)     { is_expected.to eq Date.today }

      its(:resulting_organizations) { is_expected.to match_array [@new_library, @its] }

      describe 'original_organizations' do
        it 'include historic library organization' do
          expect(subject.original_organizations.count).to eq 1
          orig = subject.original_organizations.first
          expect(orig.label).to eq 'Library and ITS'
          expect(orig.end_date).to eq Date.today
          expect(orig.memberships).to include @its_lib_admin
          expect(orig.people).to include @john
        end
      end

      describe 'resulting_organizations' do
        it 'contains new library org' do
          new_library = subject.resulting_organizations.select{ |o| o.hr_id == '1234' }.first
          expect(new_library.label).to eq 'Library'
          expect(new_library.kind).to eq 'DIV'
          expect(new_library.begin_date).to eq Date.today
          expect(new_library.sub_organizations.count).to eq 1
          expect(new_library.super_organizations.count).to eq 1
          expect(new_library.memberships).to include @lib_admin
          expect(new_library.people).to include @jane
        end
        
        it 'contains new its org' do
          its = subject.resulting_organizations.select{ |o| o.hr_id == '9876' }.first
          expect(its.label).to eq 'ITS'
        end
      end
    end

    context 'when combining two organizations' do
      before :context do
        @library = FactoryGirl.create(:library)
        @jane = FactoryGirl.create(:jane, primary_org: @library)
        @prof = FactoryGirl.create(:thayer_prof, title: 'Professor', person: @jane,
                                   organization: @library)
        @dean = FactoryGirl.create(:thayer_prof, title: 'Dean', person: @jane,
                                   organization: @library, begin_date: Date.today - 10,
                                   end_date: Date.yesterday)
        
        @its = FactoryGirl.create(:its)
        @new_library = Lna::Organization.create(label: 'Library and ITS', begin_date: Date.today,
                                                hr_id: '1234', kind: 'DIV')
        
        Lna::Organization::ChangeEvent.trigger_event(@library, @new_library,
                                                     description: 'Library absorbs ITS')
        @change_event = Lna::Organization::ChangeEvent.trigger_event(@its, @new_library)
      end

      subject { @change_event }

      its(:description)  { is_expected.to eq 'Library absorbs ITS' }
      its(:at_time)      { is_expected.to eq Date.today }
      
      its(:resulting_organizations) { is_expected.to match_array [@new_library] }

      describe 'original organizations' do 
        it 'contains two' do
          expect(subject.original_organizations.count).to eq 2
        end
        
        it 'contains historic library organization' do
          library = subject.original_organizations.select { |o| o.hr_id == '5678' }.first
          expect(library.label).to eq 'Dartmouth College Library'
          expect(library.alt_label).to eq ['Library']
          expect(library.kind).to eq 'SUBDIV'
          expect(library.hinman_box).to eq '6025'
          expect(library.begin_date).to eq Date.parse('1974-01-01')
          expect(library.end_date).to eq Date.today
          expect(library.memberships).to include @dean
          expect(library.people).not_to include @jane
        end
        
        it 'contains historic ITS organization' do
          its = subject.original_organizations.select { |o| o.hr_id == '9876' }.first
          expect(its.label).to eq 'ITS'
          expect(its.alt_label).to eq ['Computing']
          expect(its.end_date).to eq Date.today
        end
      end

      describe 'resulting organization' do
        subject { @new_library }
        
        its(:label)       { is_expected.to eq 'Library and ITS' }
        its(:begin_date)  { is_expected.to eq Date.today }
        its(:hr_id)       { is_expected.to eq '1234' }
        its(:kind)        { is_expected.to eq 'DIV' }
        its(:people)      { is_expected.to include @jane }
        its(:memberships) { is_expected.to include @prof }
        its(:memberships) { is_expected.not_to include @dean }
        
        it 'contains sub organizations' do
          expect(subject.sub_organizations.count).to eq 1
          expect(subject.sub_organizations.first.label).to eq 'Digital Library Technologies Group'
        end
        
        it 'contains super organization' do
          expect(subject.super_organizations.count).to eq 1
          expect(subject.super_organizations.first.label).to eq 'Office of the Provost'
        end
      end
    end
  end
end
