require 'stringio'

module RRTF
  # Represents a set of formatting that can be applied to paragraph and table
  # borders
  class TabStyle < AnonymousStyle

    TYPE_DICTIONARY = {
      "FLUSH_RIGHT"     => 'rqr',
      "CENTERED"        => 'tqc',
      "DECIMAL"         => 'tqdec'
    }.freeze

    LEADER_DICTIONARY = {
      "DOT"             => 'tldot',
      "MIDDLE_DOT"      => 'tlmdot',
      "HYPHEN"          => 'tlhyph',
      "UNDERLINE"       => 'tlul',
      "THICK_LINE"      => 'tlth',
      "EQUAL"           => 'tleq'
    }.freeze

    attr_accessor :type, :leader, :position

    # This is the constructor for the BorderStyle class.
    #
    # @param [Hash] options the tab style options.
    # @option options (see AnonymousStyle#initialize)
    # @option options [String] "type" (nil) the tab type ("FLUSH_RIGHT", "CENTERED", or "DECIMAL").
    # @option options [String] "leader" (nil) the leader type ("DOT", "MIDDLE_DOT","HYPHEN", "UNDERLINE", "THICK_LINE", or "EQUAL").
    # @option options [String, Integer] "position" (720) the position of the tab stop from the left margin in twips (can be a string, see {Utilities.value2twips}).
    def initialize(options = {})
       super(options)
       @type = TYPE_DICTIONARY[options.delete("type")]
       @leader = LEADER_DICTIONARY[options.delete("leader")]
       @position = Utilities.value2twips(options.delete("position")) || 720
    end

    # This method generates a string containing the prefix associated with the
    # style object. Equivalent to {#rtf_formatting} for the TabStyle class.
    def prefix(document)
      rtf_formatting
    end

    def rtf_formatting
      rtf = StringIO.new

      rtf << "\\#{@type}"       unless @type.nil?
      rtf << "\\#{@leader}"     unless @leader.nil?
      rtf << "\\tx#{@position}"

      rtf.string
    end
  end # class TabStyle
end # module RRTF
