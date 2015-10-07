module Lna
  class Collection
    class Document < ActiveFedora::Base
      include DateHelpers
      
      # is reviewed by many documents
      has_many :reviews, class_name: 'Lna::Collection::Document', inverse_of: :review_of,
               as: :review_of

      # reviews one document
      belongs_to :review_of, class_name: 'Lna::Collection::Document',
                 predicate: ::RDF::Vocab::BIBO.reviewOf
      
      belongs_to :collection, class_name: 'Lna::Collection', predicate: ::RDF::DC.isPartOf
      
      validates_presence_of :collection, :author_list, :title
      
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
    end
  end
end
