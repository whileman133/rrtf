module RRTF
  # Represents a set of formatting that can be applied to position paragraphs.
  class PositionStyle < AnonymousStyle
    include PositionFormatting

    # This is the constructor for the PositionStyle class.
    #
    # @param [Hash] options the position style options.
    # @option options (see AnonymousStyle#initialize)
    # @option options (see PositionFormatting#initialize_position_formatting)
    def initialize(options = {})
       super(options)
       initialize_position_formatting(options)
    end

    # This method generates a string containing the prefix associated with the
    # style object. Equivalent to {#rtf_formatting} for the PositionStyle class.
    def prefix(document)
      rtf_formatting(document)
    end

    def rtf_formatting(document)
      position_formatting_to_rtf(document)
    end
  end # class PositionStyle
end # module RRTF
