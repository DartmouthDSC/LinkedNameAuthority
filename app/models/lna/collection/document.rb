module Lna
  class Collection
    class Document < ActiveFedora::Base
      has_many :documents, class_name: 'Lna::Collection::Document',
               predicate: ::RDF::Vocab::BIBO.reviewOf
      
      belongs_to :collection, class_name: 'Lna::Collection',
                 predicate: ::RDF::DC.isPartOf
      
      validates_presence_of :collection, :author_list, :title
      
      type ::RDF::Vocab::BIBO.Document
      
      property :author_list, predicate: ::RDF::Vocab::BIBO.authorList, multiple: false
      property :publisher, predicate: ::RDF::DC.publisher, multiple: false
      property :date, predicate: ::RDF::DC.date, multiple: false
      property :title, predicate: ::RDF::DC.title, multiple: false
      property :page_start, predicate: ::RDF::Vocab::BIBO.pageStart, multiple: false
      property :page_end, predicate: ::RDF::Vocab::BIBO.pageEnd, multiple: false
      property :pages, predicate: ::RDF::Vocab::BIBO.pages, multiple: false
      property :volume, predicate: ::RDF::Vocab::BIBO.volume, multiple: false
      property :issue, predicate: ::RDF::Vocab::BIBO.issue, multiple: false
      property :number, predicate: ::RDF::Vocab::BIBO.number, multiple: false
      property :uri_identifier, predicate: ::RDF::Vocab::BIBO.uri
      property :doi, predicate: ::RDF::Vocab::BIBO.doi, multiple: false
    end
  end
end
