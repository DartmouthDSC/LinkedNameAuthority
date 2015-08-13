class Lna::Organization::ChangeEvent < ActiveFedora::Base
  has_many :resulting_organizations, class_name: 'Lna::Organization',
           predicate: ::RDF::Vocab::ORG.resultingOrganization,
           as: 'resulted_from'
  has_many :original_organizations, class_name: 'Lna::Organization',
           predicate: ::RDF::Vocab::ORG.originalOrganization,
           as: 'changed_by'

  validate :max_one_original_org

  validates_presence_of :resulting_organizations, :original_organizations,
                        :at_time, :description
  
  property :at_time, predicate: ::RDF::PROV.atTime, multiple: false
  property :description, predicate: ::RDF::DC.description, multiple: false


  def max_one_original_org
    if original_organizations.size > 1
      errors.add(:original_organizations, 'can\'t have more than 1 organization.')
    end
  end 
end
