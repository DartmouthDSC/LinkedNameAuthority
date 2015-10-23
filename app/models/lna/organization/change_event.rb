module Lna
  class Organization
    class ChangeEvent < ActiveFedora::Base
      include Lna::DateHelper
      
      has_many :resulting_organizations, class_name: 'ActiveFedora::Base',
               predicate: ::RDF::Vocab::ORG.resultedFrom
      has_many :original_organizations, class_name: 'Lna::Organization::Historic',
               inverse_of: :changed_by, as: :changed_by

      validates_presence_of :resulting_organizations, :original_organizations,
                            :at_time, :description
  
      property :at_time, predicate: ::RDF::PROV.atTime, multiple: false do |index|
        index.type :date
        index.as :displayable
      end
      
      property :description, predicate: ::RDF::DC.description, multiple: false do |index|
        index.as :displayable
      end
      
      def at_time=(d)
        date_setter('at_time', d)
      end

      def self.trigger_change_event(active, description, update, end_date = Date.today)
        # active must be a Lna::Organization
        raise ArgumentError, 'first parameter must be a Lna::Organization' unless active.is_a?(Lna::Organization)

        # update must contain one of the following keys
        # this check might happen in historic.
        valid_keys = [:sub_organizations, :super_organizations, :code, :alt_label, :label]
        includes_keys = update.keys.select { |k| valid_keys.include? k }
        if includes_keys.empty?
          raise ArgumentError, "update must include one of the following keys: #{valid_keys.join(", ")}."
        end
        
        historic_mems = active.memberships.to_a.select { |m| m.ended? }

        # filter out id, *_id, *_ids
        attr = active.attributes.select { |k, _| !(/(^id|.+_ids?)$/ =~ k) }
        
        # Create historic organization
        historic = Lna::Organization::Historic.create!(attr) do |h|
          h.end_date = end_date
          h.historic_placement = active.json_serialization
          h.memberships = historic_mems
        end

        # Update active organization
        active.reload # historic_memberships should be removed
        active.update_attributes(update)
        # Remove historic memberships, that are now associated with the historic organization
        
        # Make updates as requested in the hash
        
        # Create change_event
        Lna::Organization::ChangeEvent.create! do |c|
          c.at_time = end_date
          c.description = description
          c.original_organizations << historic
          c.resulting_organizations << active # sets resulted_from in active
        end

        active #return change_event object?, historic object, active?
      end

      # Method to combine two or more organizations. Converts all organization into historic
      # organizations, creates a new active organization and creates a change event.
      #
      # Active memberships of all the organizations are combined and moved to the new active
      # organizations. All accounts are combined and moved to the new active organization.
      # All the historic organizations are set to be the originating organizations of the
      # change_event, the new active organization are set to be the resulting organizations.
      #
      # @param [Array<Lna::Organization>] active_orgs Active organization to be combined. Length
      #   of array needs to be greater than one.
      # @param [String] description Description of change; will be used in change_event object.
      # @param [Hash] new_org_attr 
      # @param [Date] end_date End_date of organization, will also be set as the time the change
      #   event occured. Defaults to today's date, if none is provided.
      # @return
      def self.combine_orgs(active_orgs, description, new_org_attr, end_date = Date.today)

        raise ArgumentError, 'there must be more than one active org.' if active_orgs.length < 2

        active_mems, accounts = [], []
        active_orgs.each do |o|
          # collect all active memberhips
          active_mems << o.memberships.select { |m| m.active? }
          accounts << o.accounts # collect accounts
        end

        # people?

        # Create active organization
        new_active = Lna::Organization.create!(new_org_attr) do |o|
          o.memberships << active_mems
          o.accounts << accounts
        end
        
        # Create historic organization and destroy active
        historic_orgs = active_orgs.map do |current|
          Lna::Organization.convert_to_historic(current) 
        end

        # Create change_event
        Lna::Organization::ChangeEvent.create! do |o|
          o.at_time = end_date
          o.description = description
          o.resulting_organization << new_active
          o.original_organizations << historic_orgs
        end

        # return new active org or change event
      end

      # split only into two, how would a split for more than one work?
      def self.split_orgs(active, description, main_new_args, second_new_args, end_date)
        
      end
      
    end
  end
end
