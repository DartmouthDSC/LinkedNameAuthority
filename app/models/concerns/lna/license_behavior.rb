require 'ali'

# All models that use this module must include a :document relationship.
module Lna
  module LicenseBehavior
    extend ActiveSupport::Concern
    include Lna::DateHelper

    included do
      type ::RDF::Vocab::DC.LicenseDocument
      
      validates_presence_of :start_date, :title, :document

      validates :end_date, date: { on_or_after: :start_date }, if: :ended?
      
      property :start_date, predicate: Vocabs::ALI.start_date, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end
      
      property :end_date, predicate: Vocabs::ALI.end_date, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end
      
      property :title, predicate: ::RDF::Vocab::DC.title, multiple: false do |index|
        index.as :displayable
      end

      def start_date=(d)
        date_setter('start_date', d)
      end
      
      def end_date=(d)
        date_setter('end_date', d)
      end
      
      def ended?
        end_date != nil
      end
    end
  end
end
