module Lna
  class Collection
    class FreeToRead < ActiveFedora::Base
      include Lna::LicenseBehavior

      belongs_to :document, class_name: 'Lna::Collection::Document',
                 predicate: Vocabs::ALI.free_to_read
    end
  end
end
      
