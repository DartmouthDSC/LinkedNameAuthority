class LnaPerson < ActiveFedora::Base

  include Hydra::AccessControls::Permissions
  
  has_many :lna_appointments, dependent: :destroy,
           predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasDependent
  has_many :lna_accounts, dependent: :destroy,
           predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasDependent

  validates_presence_of :foaf_name, :foaf_given_name, :foaf_title, :foaf_mbox,
                        :foaf_mbox_sha1sum

  property :dc_netid, predicate: ::RDF::DC.identifier, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :foaf_name, predicate: ::RDF::FOAF.name, multiple: false do |index|
    index.as :stored_searchable
  end

  property :foaf_given_name, predicate: ::RDF::FOAF.givenName, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :foaf_family_name, predicate: ::RDF::FOAF.familyName, multiple: true do |index|
    index.as :stored_searchable
  end
  
  property :foaf_title, predicate: ::RDF::FOAF.title, multiple: false do |index|
    index.as :stored_searchable
  end
  
  property :foaf_image, predicate: ::RDF::FOAF.img, multiple: false do |index|
    index.as :displayable
  end
  
  property :foaf_mbox, predicate: ::RDF::FOAF.mbox, multiple: false do |index|
    index.as :displayable
  end
  
  property :foaf_mbox_sha1sum, predicate: ::RDF::FOAF.mbox_sha1sum, multiple: false
  
  property :foaf_homepage, predicate: ::RDF::FOAF.homepage, multiple: false do |index|
    index.as :displayable
  end

  property :foaf_publications, predicate: ::RDF::FOAF.publications, multiple: false do |index|
    index.as :displayable
  end
  
  property :foaf_workplace_homepage, predicate: ::RDF::FOAF.workplaceHomepage,
           multiple: false do |index|
    index.as :displayable
  end

  # Probably don't need this anymore, but maybe helpful for the time being.
  def self.get_appointments(person_id)
    appoint = Array.new
    LnaAppointment.where(isDependentOf_ssim: person_id).each do |a|
      appoint << a
    end
    appoint
  end
  
  
end
