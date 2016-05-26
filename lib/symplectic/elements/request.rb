require 'symplectic/elements/api'

module Symplectic
  module Elements
    class Request

      # Makes Elements API request with path and optional params given.
      #
      # @param [String] path request path
      # @param [DateTime|Time] modified_since filters results by date modified
      # @param [Integer] page 
      # @param [String] detail amount of detail that should be returned.
      #   Options are 'ref' and 'full'.
      # @param [Boolean] all_results paginates through result pages and returns all results
      # @return [Array<Nokogiri::XML::Element>] array of <entry> elements returned by request
      def self.get(path, modified_since: nil, page: 1, detail: 'ref', all_results: false)
        # Check that modified_since is a DateTime object.
        modified_since = modified_since.to_datetime if modified_since.instance_of?(Time)
        
        if modified_since && !modified_since.instance_of?(DateTime)
          raise RequestError, 'modified_since must be a DateTime object'
        end

        # Check that page is an Integer.
        raise RequestError, 'page must be an Integer' if page && !page.is_a?(Integer)

        # If all_results flag is true, page is set to 1.
        page = 1 if all_results

        response = Symplectic::Elements::Api.new.get(path) do |req|
          req.params['modified-since'] = URI.escape(modified_since.strftime) if modified_since
          req.params['page'] = page
          req.params['detail'] = detail
        end

        raise RequestError, "GET #{path} request returned #{response.status}." unless response.success?
        
        xml_doc = Nokogiri::XML(response.body)

        # Need to check that entry does not contain api:errors.
        unless xml_doc.xpath('/xmlns:feed/xmlns:entry/api:error').count.zero?
          raise ApiError, "GET request returned an api:error."
        end
        
        entries = xml_doc.xpath('/xmlns:feed/xmlns:entry').to_a

        # If retriving all results, calculate last page and retrive results from page 2 through
        # the last page.
        if all_results
          nodes = xml_doc.xpath("/xmlns:feed/api:pagination/api:page[@position='last']")
          if nodes.length == 1
            last_page = nodes[0].attributes['number'].value.to_i
          else
            raise ApiError, 'Error calculating number of last result page'
          end
          
          (2..last_page).each do |i|
            entries.concat Symplectic::Elements::Request.get(path,
                                                             modified_since: modified_since,
                                                             page: i,
                                                             detail: detail)
          end
        end
        
        entries
      end

    end
  end
end
