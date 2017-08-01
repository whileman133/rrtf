module RRTF
  # Parent class from which all properties classes derive.
  # @author Wesley Hileman
  # @abstract
  class Properties
    # Converts a properties object into an RTF sequence. Override in derived
    # classes.
    # @abstract
    def to_rtf
      nil
    end
  end # class Properties
end # module RRTF
