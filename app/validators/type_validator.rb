class TypeValidator < ActiveModel::EachValidator
  # Validates that the value given is of one of the types.
  # A hash with types must be present.
  # 
  # @example Usage
  #   validates :resulting_organizations,
  #             association_type: { types: [Lna::Organization, Lna::Organization::Historic] }
  # 
  def validate_each(record, attribute, value)
    if !options[:valid_types]
      raise ArgumentError, 'Need types to run association type validator.'
    elsif !options[:valid_types].kind_of?(Array)
      options[:valid_types] = Array.new(options[:valid_types])
    end
    # check that each options[:type] is a class name?
    
    if !options[:valid_types].include?(value.class)
      record.errors.add(attribute,
                        "must be a #{options[:valid_types].join(' or a ')}")
    end
  end
end
