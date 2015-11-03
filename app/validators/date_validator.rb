class DateValidator < ActiveModel::EachValidator

  CHECKS =
    {
      before: :<,
      after: :>,
      on_or_before: :<=,
      on_or_after: :>=
    }.freeze
  
  # Validates that the attribute is before or after (depending on the option select)
  # the date given. Currently, only one options can be selected. The validation
  # only runs if the attribute is set.
  # 
  #
  # @example Usage
  #   validates :end_date, date: { after: :begin_date } 
  #
  # @param [Hash] options Optional options
  # @option options [Symbol] :after
  # @option options [Symbol] :before
  # @option options [Symbol] :on_or_before
  # @option options [Symbol] :on_or_after  
  def validate_each(record, attribute, value)
    return unless record.errors.empty?     # return if there are other errors
    
    checks = options.select { |k, _| CHECKS.key?(k) }
    raise ArgumentError, 'can only have one option for date validation.' if checks.count != 1
    
    raise ArgumentError, "#{attribute} must be a Date object." unless value.instance_of? Date

    check = checks.keys[0] #before, after, on_or_before, on_or_after
    comparison_value = record.send(options[check])

    raise ArgumentError, 'comparison value is not a Date object' unless comparison_value.instance_of? Date
      
    unless cmp(value, CHECKS[check], comparison_value)
      record.errors.add(attribute, "must be #{check} #{options[check]}")
    end
  end

  private

  # Comparison method, to compare two dates based on the method given.
  def cmp(a, operator, b)
    a.send(operator, b)
  end
end
