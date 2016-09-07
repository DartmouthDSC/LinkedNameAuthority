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
  
      property :at_time, predicate: ::RDF::Vocab::PROV.atTime, multiple: false do |index|
        index.type :date
        index.as :displayable
      end
      
      property :description, predicate: ::RDF::Vocab::DC.description, multiple: false do |index|
        index.as :displayable
      end
      
      def at_time=(d)
        date_setter('at_time', d)
      end

      def to_solr
        super.tap do |solr_doc|
          unless self.resulting_organizations.size.zero?
            solr_doc['resultingOrganization_ssim'] = self.resulting_organization_ids
          end
          
          unless self.original_organizations.size.zero?
            solr_doc['originalOrganization_ssim'] = self.original_organization_ids
          end
        end
      end

      # Link two organizations through a change event.
      #
      # If the old organization has a changed by event or if the new organization has a result from
      # event, use that change event. Otherwise create a new one based using the description and
      # date given. Date and description are ignored if a change event is already present.
      #
      # If old is an active organization then:
      #   - all accounts are migreated to the new organization
      #   - all sub organizations and super organizations are copied over to the new organizations
      #   - memberships
      #       - that do not have an end date will be migrated to the new organization
      #       - that do have an end date will be move to the historic organization
      #   - people
      #       - that do not have any active memberships will move to the historic organization
      #       - that have an active membership related to old will be moved to the new organization
      #       - otherwise, person will be moved to the organization of the first active membership
      #   - change_by is set
      #
      # If old is a historic organization then:
      #   - change_by is set
      #
      # @param [Lna::Organization::Historic|Lna::Organization] old
      # @param [Lna::Organization] new
      # @param [String] description
      # @param [Date] date
      # @return [Lna::Organization::ChangeEvent]
      def self.trigger_event(old, new, description: nil, date: Date.today)
        old.reload
        new.reload
        
        if old.instance_of?(Lna::Organization::Historic) && old.changed_by && new.resulted_from
          unless old.changed_by == new.resulted_from
            raise ArgumentError, 'old.changed_by and new.resulted_from events must be the same'
          end
        end

        change_event = if old.instance_of?(Lna::Organization::Historic) && old.changed_by
                         old.changed_by
                       elsif new.resulted_from
                         new.resulted_from
                       else
                         Lna::Organization::ChangeEvent.new(
                           description: description,
                           at_time:     date
                         )
                       end
        
        # If old is an active organization it needs to be converted to a historic organization.
        if old.instance_of? Lna::Organization

          # Migrate people from old -> new, if there's an active membership still related to org.
          # If there are no active memberships, the person stays with the historic org. Otherwise,
          # it is moved to one of the orgs for which it still has an active membership.
          old.people.each do |person|
            active_mems_orgs = person.memberships
                               .select { |m| m.active_on? change_event.at_time }
                               .map(&:organization)

            next if active_mems_orgs.count.zero?

            person.primary_org = (active_mems_orgs.include? old) ?
                                   new : active_mems_orgs.first
            person.save!
          end

          # Migrate memberships that have not ended from old -> new.
          old.memberships.each do |mem|
            if mem.active_on? date
              mem.organization = new
              mem.save!
            end
          end

          # Copy sub_organizations and super_organization from old -> new.
          new.super_organizations.concat(old.super_organizations)
          new.sub_organizations.concat(old.sub_organizations)

          # Migrate accounts from old -> new.
          new.accounts = old.accounts
          
          new.save!

          # Make old historic
          old = Lna::Organization.convert_to_historic(old, date)
         end

        #byebug
        
        # Add historic to original organizations
        change_event.original_organizations << old
        old.changed_by = change_event
        
        # Add new to resulting organizations.
        new.update(resulted_from: change_event)
        new.save!

        change_event.save!
        
#        puts change_event.original_organizations.inspect
       
        change_event
      end
    end
  end
end
