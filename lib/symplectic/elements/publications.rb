require 'symplectic/elements/request'
require 'symplectic/elements/publication'
1;95;0c
module Symplectic
  module Elements
    class Publications < Request
      # Get publications for an individual. Can limit results by modified since date.
      #    /users/username-{DartmouthID}/publications
      #    /users/username-{DartmouthID}/publications?modified-since=2015-03-01T13%3A00%3A00Z
      #
      # @param [String] netid of user
      # @param [DateTime] modified_since
      # @return a list of ids?   
      def self.get(netid:, **args)
        path = "users/username-#{netid}/publications"
        args[:detail] = 'full'
        entries = super(path, **args)
        entries.map do |e|
          e = e.at_xpath("api:relationship/api:related[@direction='from']/api:object")
          Symplectic::Elements::Publication.new(e)
        end
      end
      
      def self.get_all(netid:, modified_since: nil)
        get(netid: netid, modified_since: modified_since, all_results: true)
      end
    end
  end
end
