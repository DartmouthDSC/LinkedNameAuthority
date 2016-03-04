# coding: utf-8
module Symplectic
  module Elements
    class Publication

      attr_accessor :author_list, :publisher, :date, :title, :page_start, :page_end, :pages,
                    :volume, :issue, :number, :canonical_url, :doi, :abstract

      # Creates publication object from <api:object> element returned from the Elements API.
      # Note: Each publication can have multiple records, for our purposes we are using the first
      # record, because that should be the prefered record as choosen by our admins.
      #
      #
      # @param api_object [Nokogiri::XML::Element]
      def initialize(api_object)

        # check for api:errors for errors
        
        record = api_object.at_xpath("api:records/api:record[@format='native']/api:native")
        load_from_record(record)
        
      end

      # @params record [Nokogiri::XML::Element]
      def load_from_record(record)
        xpath_queries = {
          publisher:    "api:field[@name='issue']/api:text",
          title:        "api:field[@name='title']/api:text",
          volume:       "api:field[@name='volume']/api:text",
          abstract:     "api:field[@name='abstract']/api:text",
          issue:        "api:field[@name='issue']/api:text",
          page_start:   "api:field[@name='pagination']/api:pagination/api:begin-page",
          page_end:     "api:field[@name='pagination']/api:pagination/api:end-page",
          pages:        "api:field[@name='pagination']/api:pagination/api:page-count",
          number:       "api:field[@name='number']/api:text",
          #        doi:          "api:field[@name='doi']/api:links/api:link[@type='doi']/"
        }

        # loop through all the xpath queries
        xpath_queries.each do |field, xpath|
          if element = record.at_xpath(xpath)
            send("#{field}=", element.text)
          end
        end

        extract_author_list(record.at_xpath("api:field[@name='authors']"))
        extract_date(record.at_xpath("api:field[@name='publication-date']"))
      end

      
      # Extract author list from api:field[@name='authors']
      # author list should be in the following format: [“Bell, John”, “Galarza, Carla”]
      def extract_author_list(api_field)
        return unless api_field
        people = api_field.xpath('api:people/api:person')

        authors = people.map do |person|
          last_name = person.at_xpath('api:last-name')
          first_name = person.at_xpath('api:first-names') || person.at_xpath('api:initials')
          [last_name, first_name].map(&:text).join(', ')
        end
        
        send(:author_list=, authors)
      end
      
      # extract publication date
      # should stringify date to the following format: YYYY-MM-DD
      def extract_date(api_field)
        return unless api_field
        
        year  = api_field.at_xpath('api:date/api:year')
        month = api_field.at_xpath('api:date/api:month') || '01'
        day   = api_field.at_xpath('api:date/api:day') || '01'
        date = [year, month, day].map { |i| (i.respond_to? :value) ? i.value : i }.join('-')
        send(:date=, date)
      end

      # Returns hash representation of object's instance variables
      def to_hash
        hash = {}
        instance_variables.each do |i|
          key = i.to_s.delete('@')
          hash[key] = send(key)
        end
        hash
      end
    end
  end
end
