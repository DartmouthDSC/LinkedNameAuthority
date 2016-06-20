require 'owl_time'

module Lna
  class Membership < ActiveFedora::Base
    include Lna::DateHelper

    after_save :update_primary_org
    
    SOURCE_HRMS = 'HRMS'
    SOURCE_MANUAL = 'Manual'
    
    belongs_to :person, class_name: 'Lna::Person',
               predicate: ::RDF::Vocab::ORG.hasMember
    belongs_to :organization, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.Organization

    validates_presence_of :person, :organization, :title, :begin_date
    
    validates :organization,
              type: { valid_types: [Lna::Organization, Lna::Organization::Historic] }

    validates :end_date, date: { on_or_after: :begin_date }, if: :end_date_set?
    
    property :title, predicate: ::RDF::Vocab::VCARD.title, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :email, predicate: ::RDF::Vocab::VCARD.email, multiple: false do |index|
      index.as :displayable
    end
    
    property :street_address, predicate: ::RDF::Vocab::VCARD['street-address'],
             multiple: false do |index|
      index.as :displayable
    end
    
    property :pobox, predicate: ::RDF::Vocab::VCARD['post-office-box'], multiple: false do |index|
      index.as :displayable
    end
    
    property :locality, predicate: ::RDF::Vocab::VCARD.locality, multiple: false do |index|
      index.as :displayable
    end
  
    property :postal_code, predicate: ::RDF::Vocab::VCARD['postal-code'], multiple: false do |index|
      index.as :displayable
    end
    
    property :country_name, predicate: ::RDF::Vocab::VCARD['country-name'],
           multiple: false do |index|
      index.as :displayable
    end
    
    property :begin_date, predicate: Vocabs::OwlTime.hasBeginning, multiple: false do |index|
      index.type :date
      index.as :stored_searchable
    end

    property :end_date, predicate: Vocabs::OwlTime.hasEnd, multiple: false do |index|
      index.type :date
      index.as :stored_searchable
    end

    property :source, predicate: ::RDF::Vocab::VCARD.hasSource, multiple: false do |index|
      index.as :stored_searchable
    end
    
    def begin_date=(d)
      date_setter('begin_date', d)
    end

    def end_date=(d)
      date_setter('end_date', d)
    end

    # Checks whether or not an end_date is set, ignores what the date actually is.
    #
    # @return [false] if date is not set.
    # @return [true] if date is set
    def end_date_set?
      end_date != nil
    end

    # Returns whether or not this membership was ended.
    #
    # @return [false] if the membership was active
    # @return [true] if the membership was not active
    def ended?
      !active_on?(Date.today)
    end

    # Returns whether or not this membership is active today.
    #
    # @return [false] if membership is not active today
    # @return [true] if membership is active today
    def active?
      active_on?(Date.today)
    end

    # Returns whether or not this membership was active on the date specified.
    #
    # @param [Date] date to be checked
    # @return [false] if the date given is after or on the end_date or before the begin_date
    # @return [true] if the end_date is not set and the date given is after or on the begin_date
    # @return [true] if the date is before but not on the end_date
    def active_on?(date)
      begin_date <= date && (end_date == nil || end_date > date)
    end


    private

    # Update person's primary organization if there is another active membership with an active
    # organization. 
    def update_primary_org
      return if self.end_date.blank? || person.nil?

      person.reload # Make sure we have the most accurate version.
      
      if self.previous_changes.include?(:end_date) 
        # Check to see if primary membership matches membership's organization, if so look for a
        # more accurate primary membership.
        if organization == person.primary_org
          mems = person.memberships.select do |m|
            m.active_on?(self.end_date) && m.organization.active?
          end
        
          if mems.count > 0
            person.primary_org = mems.first.organization
            person.save!
          end
        end
      end
    end
  end
end
