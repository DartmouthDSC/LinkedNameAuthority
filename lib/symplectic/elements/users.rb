require 'symplectic/elements/request'
require 'symplectic/elements/user'

module Symplectic
  module Elements
    class Users < Request
      # Look up users by id or by date last modified. If a netid is passed in, the search cannot
      # also be limited by modified_since and page.
      #   /users/username-{DartmouthID}
      #   /users?modified-since={modified-since}
      #
      # @param [String] netid of user
      # @param [DateTime] modified_since limit results by records that were modified since the date
      #   given
      # @param [Integer] page results page
      # @return [Array<Symplectic::Elements::User>] array of user objects
      def self.get(netid: nil, modified_since: nil, page: nil, all_results: false)
        # Check that its a valid net id

        # If netid is set, modified_since and page should not be set.
        if netid && (modified_since || page)
          raise 'netid parameter cannot be used in conjunction with modified_since and page'
        end

        path = 'users'
        path << "/username-#{netid}" if netid

        entries = super(path, modified_since: modified_since, page: page, all_results: all_results)

        entries.map do |e|
          e = e.at_xpath('api:object')
          Symplectic::Elements::User.new(e)
        end
      end

      # like .get but get_all iterates through all the result pages
      #
      #
      #
      def self.get_all(netid: nil, modified_since: nil)
        get(netid: netid, modified_since: nil, page: 1, all_results: true)
      end
        
    end
  end
end
