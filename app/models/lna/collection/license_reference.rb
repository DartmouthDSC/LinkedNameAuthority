module Lna
  class Collection
    class LicenseReference < ActiveFedora::Base
      include Lna::LicenseBehavior
      
      belongs_to :document, class_name: 'Lna::Collection::Document',
                 predicate: Vocabs::ALI.license_ref

      validates_presence_of :license_uri
      
      property :license_uri, predicate: Vocabs::ALI.uri, multiple: false do |index|
        index.as :displayable
      end
    end
  end
end
