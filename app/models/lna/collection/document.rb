class Lna::Collection::Document < ActiveFedora::Base
  has_many :documents, class_name: 'Lna::Collection::Document',
           predicate: ::RDF::Vocab::BIBO.reviewOf
  
  belongs_to :collection, class_name: 'Lna::Collection',
             predicate: ::RDF::DC.isPartOf

  validates_presence_of :collection
  
  property :author_list, predicate: ::RDF::Vocab::BIBO.authorList
  property :publisher, predicate: ::RDF::DC.publisher
  property :date, predicate: ::RDF::DC.date, multiple: false
  property :title, predicate: ::RDF::DC.title
  property :page_start, predicate: ::RDF::Vocab::BIBO.pageStart, multiple: false
  property :page_end, predicate: ::RDF::Vocab::BIBO.pageEnd, multiple: false
  property :pages, predicate: ::RDF::Vocab::BIBO.pages
  property :volume, predicate: ::RDF::Vocab::BIBO.volume
  property :issue, predicate: ::RDF::Vocab::BIBO.issue
  property :number, predicate: ::RDF::Vocab::BIBO.number
  property :uri_identifier, predicate: ::RDF::Vocab::BIBO.uri
  property :doi, predicate: ::RDF::Vocab::BIBO.doi
  
end
