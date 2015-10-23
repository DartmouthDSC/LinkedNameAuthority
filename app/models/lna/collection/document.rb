module Lna
  class Collection
    class Document < ActiveFedora::Base
      include DateHelper
      
      # is reviewed by many documents
      has_many :reviews, class_name: 'Lna::Collection::Document', dependent: :destroy,
               inverse_of: :review_of, as: :review_of

      # reviews one document
      belongs_to :review_of, class_name: 'Lna::Collection::Document',
                 predicate: ::RDF::Vocab::BIBO.reviewOf
      
      belongs_to :collection, class_name: 'Lna::Collection', predicate: ::RDF::DC.isPartOf

      # Assures that a document is part of a collection or a review of a document, but not both.
      validate :part_of_collection_or_review_of

      validates_presence_of :author_list, :title
            
      type ::RDF::Vocab::BIBO.Document
      
      property :author_list, predicate: ::RDF::Vocab::BIBO.authorList, multiple: false do |index|
        index.as :stored_searchable
      end
      
      property :publisher, predicate: ::RDF::DC.publisher, multiple: false do |index|
        index.as :displayable
      end
      
      property :date, predicate: ::RDF::DC.date, multiple: false do |index|
        index.as :displayable
      end
      
      property :title, predicate: ::RDF::DC.title, multiple: false do |index|
        index.as :stored_searchable
      end
      
      property :page_start, predicate: ::RDF::Vocab::BIBO.pageStart, multiple: false do |index|
        index.as :displayable
      end
      
      property :page_end, predicate: ::RDF::Vocab::BIBO.pageEnd, multiple: false do |index|
        index.as :displayable
      end
      
      property :pages, predicate: ::RDF::Vocab::BIBO.pages, multiple: false do |index|
        index.as :displayable
      end
      
      property :volume, predicate: ::RDF::Vocab::BIBO.volume, multiple: false do |index|
        index.as :displayable
      end
      
      property :issue, predicate: ::RDF::Vocab::BIBO.issue, multiple: false do |index|
        index.as :displayable
      end
      
      property :number, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
        index.as :displayable
      end
      
      property :canonical_uri, predicate: ::RDF::Vocab::BIBO.uri do |index|
        index.as :displayable
      end

      property :doi, predicate: ::RDF::Vocab::BIBO.doi, multiple: false do |index|
        index.as :stored_searchable
      end

      def date=(d)
        date_setter('date', d)
      end

      private

      # Document must be part of a collection or be a review of a document.
      # It cannot be both.
      def part_of_collection_or_review_of
        if self.collection && self.review_of
          errors[:base] << 'Document cannot be a part of a collection and a review.'
        elsif !self.collection && !self.review_of
          errors[:base] << 'Document must be a part of a collection or a review, but not both.'
        end
      end
    end
  end
end