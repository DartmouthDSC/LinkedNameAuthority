module Lna
  module DateHelper
    extend ActiveSupport::Concern

    # Helper to set date values. Converts dates, in Date or String format, to a RDF::Literal.
    #
    # @param [String] name of field to be set
    # @param [String|Date|DateTime|Time|nil] d value of field 
    def date_setter(name, d)
      case d.class.name
      when 'RDF::Literal::Date', 'NilClass'
        value = d
      when 'String'
        begin
          if d.empty?
            value = nil
          else
            value = ::RDF::Literal.new(Date.parse(d))
          end
        rescue
          raise ArgumentError, "#{name} could not be converted to a date."
        end
      when 'Date', 'DateTime', 'Time'  
        value = ::RDF::Literal.new(Date.parse(d.to_s))
      else
        raise ArgumentError, "#{name} cannot be a #{d.class}."
      end
      
      set_value(name, value)  
    end

    # Convert the date fields in the hash given to a date format that solr can understand.
    #
    # @param [Hash] values hash of values
    # @param [Array<String>] keys list of keys that represent dates
    # @return [Hash] hash with replacement keys for keys given
    def self.solr_date(values, keys)
      # Change keys for dates and convert date string to a solr friendly format.
      keys.each do |key|
        if values.key?(key) && (values[key].is_a?(String) || values[key].is_a?(Date))
          date = values.delete(key)
          date = date.to_s if date.is_a?(Date)
          values[key.to_s.concat('_dtsi').to_sym] = Date.parse(date).strftime('%FT%TZ')
        end
      end
      values
    end
  end
end
