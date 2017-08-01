module RRTF
  class Utilities
    def self.constantize(string)
      string.split('::').inject(Object) {|o,c| o.const_get c}
    end

    def self.parse_string_with_units(value)
      return nil if value.nil?
      matches = value.match /([+\-]?(\d*\.)?\d+)([a-z\%]*)$/i
      RTFError.fire("Invalid units string '#{value}'.") if matches.nil?
      [matches[1].to_f, matches[3]]
    end

    def self.num2pt(num, units)
      case units
      when 'in'
        (num * 72.0)
      when 'cm'
        (num * 28.3464567)
      when 'mm'
        (num * 2.83464567)
      when 'pt'
        (num)
      when 'twip'
        (num.to_f / 20.0)
      when 'none'
        (num)
      else
        RTFError.fire("Invalid unit '#{units}'.")
      end # case
    end

    # Converts a string representing a single value with an optional units
    # suffix into an integer representing the value in twips (twentieth points).
    # Supported unit suffixes are 'in' (inches), 'cm' (centimeters), 'mm'
    # (millimeters), and 'pt' (typographic points).
    # @note The RTF standard requires many values to be specified in twips
    #   (twentieth points), hence the need for this method.
    #
    # @param [Integer, String] value the string from which to parse the value (passes integers and nil without modification).
    # @return [Integer] the parsed value in twips.
    # @raise [RTFError] if the string cannot be converted into a value.
    def self.value2twips(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      num, units = parse_string_with_units(value)
      units ||= 'none'

      (num2pt(num, units) * 20.0).round
    end

    # Convert to quarter points.
    # @see .value2twips
    def self.value2quarterpt(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      num, units = parse_string_with_units(value)
      units ||= 'none'

      (num2pt(num, units) * 4.0).round
    end

    # Convert to half points.
    # @see .value2twips
    def self.value2halfpt(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      num, units = parse_string_with_units(value)
      units ||= 'none'

      (num2pt(num, units) * 2.0).round
    end

    # Convert to Microsoft's "English Metric Unit" (EMU).
    # @see .value2twips
    def self.value2emu(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      num, units = parse_string_with_units(value)
      units ||= 'none'

      # 12700 EMUs per point
      (num2pt(num, units) * 12700.0).round
    end

    # Convert to frational geometry units (1/65536 of a regular unit).
    def self.value2geomfrac(value)
      return nil if value.nil?
      (value * 65536.0).round
    end

    # Convert to a Boolean value into a geometry Boolean (0 or 1).
    def self.value2geombool(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      value ? 1 : 0
    end

    # Converts a string representing a single value with an optional units
    # suffix into an integer representing the value in hundreths of a percent.
    # Supported unit suffixes are '%' (percent).
    #
    # @param [Integer, String] value the string from which to parse the value (passes integers and nil without modification).
    # @return [Integer] the parsed value in hundreths of a percent.
    # @raise [RTFError] if the string cannot be converted into a value.
    def self.value2hunpercent(value)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      num, units = parse_string_with_units(value)
      units ||= 'none'

      case units
      when '%'
        (num * 100.0).round
      when 'none'
        (num).round
      else
        RTFError.fire("Invalid unit '#{units}'.")
      end # case
    end
  end # class Utilities

  class RTFError < StandardError
    def initialize(message=nil)
      super(message == nil ? 'No error message available.' : message)
    end

    def RTFError.fire(message=nil)
      raise RTFError.new(message)
    end
  end # class RTFError
end # module RRTF
