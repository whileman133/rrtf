module RRTF::Page
  # Represents the left, right, top, and bottom margin in a document page.
  # @author Wesley Hileman
  # @since 1.0.0
  class Margin
    attr_accessor :left, :right, :top, :bottom

    # Extracts a margin object from a string.
    # @see .parse_string
    #
    # @param (see {.parse_string})
    # @return [Margin] the margin object created from the string.
    # @example Parse margin from a String
    #   Margin.from_string("12.1pt, 2.2in, 5cm, 4in")
    #   # => #<RRTF::Margin:0x007fa1b3094500 @left=242, @right=3168, @top=2834, @bottom=5760>
    def self.from_string(string)
      self.new(parse_string(string))
    end

    # Extracts a margin hash from a string.
    # @param [String] string the string from which to parse the margin, taking
    #   one of the following formats: "<marg:all>", "<marg:lr>,<marg:tb>", or
    #   "<marg:l>,<marg:r>,<marg:t>,<marg:b>" where each number may be suffixed
    #   by an optional unit (see {Utilities.value2twips}).
    # @return [Hash<String, Integer>] the margin hash created from the string.
    # @raise [RTFError] if the string cannot be converted into a margin hash.
    # @example Parse margin from a String
    #   Margin.parse_string("12.1pt, 2.2in, 5cm, 4in")
    #   # => {"top"=>2834, "bottom"=>5760, "left"=>242, "right"=>3168} (twips)
    def self.parse_string(string)
      values = string.split(',').map(&:strip).collect{ |str| RRTF::Utilities.value2twips(str) }
      case values.length
      when 1
        tblr = values.first
        {"top" => tblr, "bottom" => tblr, "left" => tblr, "right" => tblr}
      when 2
        tb = values.last
        lr = values.first
        {"top" => tb, "bottom" => tb, "left" => lr, "right" => lr}
      when 4
        l = values[0]
        r = values[1]
        t = values[2]
        b = values[3]
        {"top" => t, "bottom" => b, "left" => l, "right" => r}
      else
        RRTF::RTFError.fire("Invalid margin '#{string}'.")
      end # case
    end

    # Builds a new margin object from a string or hash.
    # @note Margins are stored internally in twentieth points (twips).
    # @see .from_string
    # @see .parse_string
    # @see RRTF::Utilities.value2twips
    #
    # @param [String, Hash] value the value from which to parse the margin.
    # @option value [Integer] "left" the left margin in twips.
    # @option value [Integer] "right" the right margin in twips.
    # @option value [Integer] "top" the top margin in twips.
    # @option value [Integer] "bottom" the bottom margin in twips.
    def initialize(value = nil)
      options = {
        # default 1 inch margins
        "left" => 1440,
        "right" => 1440,
        "top" => 1440,
        "bottom" => 1440
      }

      case value
      when String
        options = options.merge(self.class.parse_string(value))
      when Hash
        options = options.merge(value)
      when nil
      else
        RRTF::RTFError.fire("Cannot create margin from '#{value}'.")
      end # case

      @left = options.delete("left")
      @right = options.delete("right")
      @top = options.delete("top")
      @bottom = options.delete("bottom")
    end # initialize

    def ==(obj)
      obj.class == self.class && obj.state == state
    end
    alias_method :eql?, :==

    protected

    def state
      [@left, @top, @right, @bottom]
    end
  end # class Margin
end # module Page
