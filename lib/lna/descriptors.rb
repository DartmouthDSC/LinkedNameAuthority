# Customized Solrizer descriptors; based on the Solrizer::DefaultDescriptor class.
# These customizations were need to specify multiple vs. single solr fields.
module Lna
  class Descriptors

    # The suffix produced depends on the type parameter -- produces suffixes:
    #  _tesim - for strings or text fields
    #  _dtsim - for dates
    #  _isim - for integers
    def self.multiple_stored_searchable
      @multiple_stored_searchable ||= Solrizer::Descriptor.new(
        lambda { |type| stored_searchable_builder(type, true) },
        converter: searchable_converter,
        requires_type: true
      )
    end
    
    #  _tesi - for strings or text fields
    #  _dtsi - for dates
    #  _isi - for integers
    def self.stored_searchable
      @stored_searchable ||= Solrizer::Descriptor.new(
        lambda { |type| stored_searchable_builder(type, false) },
        converter: searchable_converter,
        requires_type: true, 
      )
    end

    # _ssm suffix - for all field types
    def self.multiple_displayable
      Solrizer::DefaultDescriptors.displayable
    end

    # _ss suffix - for all field types
    def self.displayable
      @displayable ||= Solrizer::Descriptor.new(:string, :stored)
    end

    # Fields that are both stored and sortable
    #  _ssi suffix - if field_type is string
    #  _dtsi suffix - if field_type is date
    def self.stored_sortable
      Solrizer::DefaultDescriptors.stored_sortable
    end

    # This is useful for when you only want to match whole words, such as user/group names
    # from the the rightsMetadata datastream
    # _ssim suffix - for all field types
    def self.symbol
      Solrizer::DefaultDescriptors.symbol
    end

    protected

    # multivalued should be true or false
    def self.stored_searchable_builder(type, multivalued)
      type = :text_en if [:string, :text].include?(type)
      multivalued = false if type == :boolean
      field =  [type, :indexed, :stored]
      field << :multivalued if multivalued
      field
    end
    
    def self.searchable_converter
      lambda do |type|
        case type
        when :date, :time
          lambda { |val| iso8601_date(val)}
        end
      end
    end
    
    def self.iso8601_date(value)
      begin
        if value.is_a?(Date) || value.is_a?(Time)
          DateTime.parse(value.to_s).to_time.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        elsif !value.empty?
          DateTime.parse(value).to_time.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      rescue ArgumentError => e
        raise ArgumentError, "Unable to parse `#{value}' as a date-time object"
      end
    end
  end
end
