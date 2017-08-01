module RRTF
  # Represents a set of formatting that can be applied to shade paragraphs.
  class ShadingStyle < AnonymousStyle
    include ShadingFormatting

    # This is the constructor for the ShadingStyle class.
    #
    # @param [Hash] options the shading style options.
    # @option options (see AnonymousStyle#initialize)
    # @option options (see ShadingFormatting#initialize_shading_formatting)
    def initialize(options = {})
       super(options)
       initialize_shading_formatting(options)
    end

    # This method generates a string containing the prefix associated with the
    # style object. Equivalent to {#rtf_formatting} for the ShadingStyle class.
    def prefix(document)
      rtf_formatting(document)
    end

    def rtf_formatting(document)
      shading_formatting_to_rtf(document)
    end
  end # class ShadingStyle
end # module RRTF
