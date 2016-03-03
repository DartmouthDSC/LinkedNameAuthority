module Symplectic
  module Elements
    class Publication

      XPATH_MAP = {
        publisher:    "api:field[@name='issue']/api:text"
        title:        "api:field[@name='title']/api:text",
        volume:       "api:field[@name='volume']/api:text",
        abstract:     "api:field[@name='abstract']/api:text",
        issue:        "api:field[@name='issue'/api:text",
        page_start:   "api:field[@name='pagination']/api:pagination/api:begin-page",
        page_end:     "api:field[@name='pagination']/api:pagination/api:end-page",
        pages:        "api:field[@name='pagination']/api:pagination/api:page-count",
        number:       "api:field[@name='number']/api:text",
#        authors_list: "",
#        date:         "",  publication date
#        doi:          "api:field[@name='doi']/api:links[@type='doi']/"
      }
      
      attr_accessor :authors_list, :publisher, :date, :title, :page_start, :page_end, :pages,
                    :volume, :issue, :number, :canonical_url, :doi

      # Creates publication object from <api:object> element returned from the Elements API.
      # Note: Each publication can have multiple records, for our purposes we are using the first
      # record, because that should be the prefered record as choosen by our admins.
      #
      #
      # @param api_object [Nokogiri::XML::Element]
      def intialize(api_object)

        # check for api:errors for errors
        
        record = api_object.at_xpath("api:records/api:record[format='native']/api:native")
        load_from_record(record)
        
      end

      def load_from_record(record)
      end
      
    end
  end
end
