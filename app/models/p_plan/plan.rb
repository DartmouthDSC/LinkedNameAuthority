module PPlan
  class Plan < ActiveFedora::Base
    has_many :steps, class_name: 'PPlan::Step', inverse_of: :plan,
             dependent: :destroy
    
    validates_presence_of :steps, :description, :title
    
    property :description, predicate: ::RDF::Vocab::DC.description, multiple: false
    property :title, predicate: ::RDF::Vocab::DC.title, multiple: false
  end
end
