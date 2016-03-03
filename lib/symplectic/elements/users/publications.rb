require 'symplectic/elements/request'

module Symplectic
  module Elements
    class User
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
          entries = super(path, **args)
          entries.map do |e|
            e = e.at_xpath("api:relationship/api:related[direction='from']/api:object")
            Symplectic::Elements::Publication.new(e)
          end
        end

        def self.get_all(netid:, modified_since: nil, detail: 'ref')
          get(netid, modified_since: modified_since, detail: detail, page: 1, all_results: true)
        end
      end
    end
  end
end
