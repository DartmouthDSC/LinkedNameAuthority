class PPlan::Step < ActiveFedora::Base

  has_many :next, class_name: 'PPlan::Step', inverse_of: :previous,
           as: :previous
  
  belongs_to :previous, class_name: 'PPlan::Step',
             predicate: ::RDF::Vocab::PPLAN.isPrecededBy
  belongs_to :plan, class_name: 'PPlan::Plan', predicate: ::RDF::Vocab::PPLAN.isStepOfPlan
  # belongs_to :user # Needs a predicate.

  validate :has_one_next, :previous_is_not_used
  validates_presence_of :plan, :description, :title
  
  property :description, predicate: ::RDF::DC.description, multiple: false
  property :title, predicate: ::RDF::DC.title, multiple: false

  def has_one_next
    if self.next.size > 1
      errors.add(:next, 'can\'t have more than one next step.')
     end
  end

  # Assure that the step :previous is set to isn't set to be another step's previous
  def previous_is_not_used
    if previous
      PPlan::Step.all.each do |s|
        if s.previous == previous && s.id != id
          errors.add(:previous, 'can\' be set to the previous of two different steps.')
        end
      end
    end
  end
end
