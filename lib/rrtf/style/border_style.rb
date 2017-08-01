module RRTF
  # Represents a set of formatting that can be applied to paragraph and table
  # borders
  class BorderStyle < AnonymousStyle
    include BorderFormatting

    # This is the constructor for the BorderStyle class.
    #
    # @param [Hash] options the character style options.
    # @option options (see AnonymousStyle#initialize)
    # @option options (see BorderFormatting#initialize_border_formatting)
    def initialize(options = {})
       super(options)
       initialize_border_formatting(options)
    end

    # This method generates a string containing the prefix associated with the
    # style object. Equivalent to {#rtf_formatting} for the BorderStyle class.
    def prefix(document)
      rtf_formatting(document)
    end

    def rtf_formatting(document)
      border_formatting_to_rtf(document)
    end
  end # class BorderStyle
end # module RRTF
