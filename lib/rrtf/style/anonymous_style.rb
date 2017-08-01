module RRTF
  # Represents an arbitrary style that can be applied to an element within an
  # RTF document (e.g. paragraph, characters, border, table, etc.)
  #
  # @author Wesley Hileman
  # @since 1.0.0
  # @abstract
  class AnonymousStyle
    # Constructor (empty for now).
    def initialize(options = {})
    end

    # This method retrieves the command prefix text associated with a Style
    # object. This method always returns nil and should be overridden by
    # derived classes as needed.
    # @abstract
    def prefix(document)
       nil
    end

    # This method retrieves the command suffix text associated with a Style
    # object. This method always returns nil and should be overridden by
    # derived classes as needed.
    # @abstract
    def suffix(document)
       nil
    end

    # Generates a string containing an RTF sequence that describes the
    # formatting present in the style. Override in derived classes.
    # @abstract
    def rtf_formatting
      nil
    end

    # Pushes the colour objects present in formatting attributes onto the
    # supplied colour table.
    # @note All colours used in an RTF document must appear in the document's
    #   header as a colour table. This method assists in generating that table.
    #
    # @param [ColourTable] colours the table in which the formatting
    #   colours will be stored.
    def push_colours(colours)
      colours << foreground_color unless !respond_to?(:foreground_color) || foreground_color.nil?
      colours << background_color unless !respond_to?(:background_color) || background_color.nil?
      colours << underline_color unless !respond_to?(:underline_color) || underline_color.nil?
      colours << highlight_color unless !respond_to?(:highlight_color) || highlight_color.nil?
      colours << color unless !respond_to?(:color) || color.nil?

      # border
      border.each do |b|
        colours << b.color unless b.color.nil?
      end unless !respond_to?(:border) || border.nil?

      # shading
      unless !respond_to?(:shading) || shading.nil?
        colours << shading.background_color unless shading.background_color.nil?
        colours << shading.foreground_color unless shading.foreground_color.nil?
      end
    end

    # Pushes the font objects present in formatting attributes onto the
    # supplied font table.
    # @note All fonts used in an RTF document must appear in the document's
    #   header as a font table. This method assists in generating that table.
    #
    # @param [FontTable] fonts the table in which the character formatting
    #   fonts will be stored.
    def push_fonts(fonts)
      fonts << font unless font.nil?
    end
  end
end # module RRTF
