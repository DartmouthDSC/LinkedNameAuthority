require 'symplectic/elements/request'
require 'symplectic/elements/publication'

module Symplectic
  module Elements
    class Publications < Request
      # Get publications for an individual on a per-page basis. Can limit results by modified
      # since date. If page parameter not present, the first page of results are returned. 
      #
      # @param [String] netid of user
      # @param [Integer] page results page
      # @param [DateTime|Time] modified_since filter by date last modified
      # @return [Array<Symplectic::Elements::Publication>] array of publication objects
      def self.get(netid:, **args)
        raise RequestError, 'netid cannot be nil' unless netid
        
        path = "users/username-#{netid}/publications"
        args[:detail] = 'full'
        
        entries = super(path, **args)

        entries.map do |e|
          e = e.at_xpath("api:relationship/api:related[@direction='from']/api:object")
          Symplectic::Elements::Publication.new(e)
        end
      end

      # Like self.get, but self.get_all iterates through all results.
      #
      # @param [String] netid of user
      # @param [DateTime|Time] modified_since
      # @return [Array<Symplectic::Elements::Publication>] array of publication objects
      def self.get_all(netid:, modified_since: nil)
        get(netid: netid, modified_since: modified_since, all_results: true)
      end
    end
  end
end
