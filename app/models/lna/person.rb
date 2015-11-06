module Lna
  class Person < ActiveFedora::Base
  
    has_many :memberships, class_name: 'Lna::Membership', dependent: :destroy
    has_many :accounts, class_name: 'Lna::Account', dependent: :destroy,
             as: :account_holder, inverse_of: :account_holder
    has_many :collections, class_name: 'Lna::Collection', dependent: :destroy

    belongs_to :primary_org, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.reportsTo

    # Create collection when the object is first created.
    after_initialize :create_collection, if: :new_record?
    
    validates_presence_of :primary_org, :full_name, :given_name, :family_name
    
    validates :collections, length_is_one: true
    
    validates :primary_org, type: { valid_types: [Lna::Organization, Lna::Organization::Historic] }
    
    type ::RDF::Vocab::FOAF.Person
  
    property :full_name, predicate: ::RDF::Vocab::FOAF.name, multiple: false do |index|
      index.as :displayable
    end

    property :given_name, predicate: ::RDF::Vocab::FOAF.givenName, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :family_name, predicate: ::RDF::Vocab::FOAF.familyName, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :title, predicate: ::RDF::Vocab::FOAF.title, multiple: false do |index|
      index.as :displayable
    end
    
    property :image, predicate: ::RDF::Vocab::FOAF.img, multiple: false do |index|
      index.as :displayable
    end
    
    property :mbox, predicate: ::RDF::Vocab::FOAF.mbox, multiple: false do |index|
      index.as :displayable
    end
    
    property :mbox_sha1sum, predicate: ::RDF::Vocab::FOAF.mbox_sha1sum, multiple: false do |index|
      index.as :stored_searchable
    end
    
    property :homepage, predicate: ::RDF::Vocab::FOAF.homepage do |index|
      index.as :stored_searchable
    end  

    # Find memberships for this person that match based on the given hash.
    # Only two fields are used as matching points. Any other fields are
    # ignored.
    #
    # @example Usage
    #   m = { title: 'Programmer/Analyst',
    #         org: { code: 'Lib' }
    #       }
    #   person.matching_membership(m)
    #
    # @param hash [Hash] membership information
    # @raise [Exception] if more than one membership matched
    # @return [Lna::Membership] if a matching membership was found
    # @return [false] if a matching membership was not found
    def matching_membership(hash)
      matching = self.memberships.to_a.select do |m|
        m.title.casecmp(hash[:title]).zero? &&
          m.organization.code.casecmp(hash[:org][:code]).zero?
      end
      raise 'More than one membership was a match for the given hash.' if matching.count > 1
      return matching.count == 1 ? matching.first : false
    end

    private
    
    def create_collection
      if collections.size == 0 # empty? creates a really odd behavior
        collections << Lna::Collection.create(person: self)
      end
    end
  end
end
