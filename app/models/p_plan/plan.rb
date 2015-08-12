module PPlan
  class Plan < ActiveFedora::Base
    has_many :steps, class_name: 'PPlan::Step', inverse_of: :plan,
             dependent: :destroy
    
    validates_presence_of :steps, :description, :title
    
    property :description, predicate: ::RDF::DC.description, multiple: false
    property :title, predicate: ::RDF::DC.title, multiple: false
  end
end
