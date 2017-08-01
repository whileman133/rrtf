module RRTF::Page
  # Represents the size of a page (width and height).
  # @author Wesley Hileman
  # @since 1.0.0
  class Size
    attr_accessor :width, :height

    # Dictionary of standard paper sizes in twips.
    DICTIONARY = {
      "A0"                  => {"width" => 47685, "height" => 67416},
      "A1"                  => {"width" => 33680, "height" => 47685},
      "A2"                  => {"width" => 23814, "height" => 33680},
      "A3"                  => {"width" => 16840, "height" => 23814},
      "A4"                  => {"width" => 11907, "height" => 16840},
      "A5"                  => {"width" => 8392, "height" => 11907},
      "LETTER"              => {"width" => 12247, "height" => 15819},
      "LEGAL"               => {"width" => 12247, "height" => 20185},
      "EXECUTIVE"           => {"width" => 10773, "height" => 14402},
      "LEDGER_TABLOID"      => {"width" => 15819, "height" => 24494}
    }.freeze

    # Converts a string representing a paper size into a paper object.
    # @see .parse_string
    #
    # @param (see {.parse_string})
    # @return [Size] the paper object representing the width & height of the paper.
    def self.from_string(string)
      self.new(self.parse_string(string))
    end

    # Converts a string representing a paper size into an ordered pair
    # (a two-item array) representing the width and height of the paper.
    # @see Utilities.value2twips
    #
    # @param [String] string the string to be parsed that can take on one of
    #   two formats: (1) "<SIZE>" where SIZE is an entry in {DICTIONARY}
    #   or (2) "WIDTH, HEIGHT" where WIDTH and HEIGHT are width and height
    #   strings with optional units suffix (see {Utilities.value2twips},
    #   default is twips)
    # @return [Hash<String, Integer>] the ordered pair (hash with keys "width" and "height")
    #   representing the width and height of the paper.
    def self.parse_string(string)
      # first, try to lookup in size dictionary
      size = DICTIONARY[string]
      return size unless size.nil?

      # if not found, try to extract width and height from string
      parts = string.split(',').map(&:strip).map{ |str| RRTF::Utilities.value2twips(str) }
      if parts.length == 2
        return {"width" => parts [0], "height" => parts[1]}
      end # if

      # unable to parse string
      RTFError.fire("Unable to parse size from string '#{string}'.")
    end

    # This is the constructor for the Paper class. All dimension parameters
    # to this method are in twips.
    # @note Paper size is stored internally in twentieth points (twips).
    # @see .from_string
    # @see .parse_string
    # @see RRTF::Utilities.value2twips
    #
    # @param [String, Hash] value from which to parse the size.
    # @option value [Integer] "width" the width of the paper in portrait mode (twips).
    def initialize(value = nil)
      # default options
      options = {
        "width" => 12247,
        "height" => 15819
      }

      case value
      when String
        options = options.merge(self.class.parse_string(value))
      when Hash
        options = options.merge(value)
      when nil
      else
        RRTF::RTFError.fire("Invalid page size format #{value}.")
      end # case

      @width  = options.delete("width")
      @height = options.delete("height")
    end

    def ==(obj)
      obj.class == self.class && obj.state == state
    end
    alias_method :eql?, :==

    protected

    def state
      [@width, @height]
    end
  end # class Size
end # module Page
