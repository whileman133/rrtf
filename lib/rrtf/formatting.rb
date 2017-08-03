require 'stringio'

# Character formatting attributes & methods shared between style types.
# @author Wesley Hileman
# @since 0.0.2
module RRTF::CharacterFormatting
  # Formatting attributes that can be applied to any text in an RTF document.
  # @return [Hash<String, Hash>] a hash mapping each attribute to a hash that
  #  describes (1) the attribute's default value, (2) how to parse the attribute
  #  from the user, and (3) how to convert the attribute to an RTF sequence.
  CHARACTER_ATTRIBUTES = {
    # toggable attributes
    "bold" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\b' : '\b0') unless value.nil? }
    },
    "italic" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\i' : '\i0') unless value.nil? }
    },
    "underline" => {
      "default" => nil,
      "dictionary" => {
        "SINGLE" => "",
        "DOUBLE" => "db",
        "THICK" => "th",
        "DASH" => "dash",
        "LONG_DASH" => "ldash",
        "DOT" => "d",
        "DASH_DOT" => "dashd",
        "DASH_DOT_DOT" => "dashdd",
        "WAVE" => 'wave',
        "THICK_DASH" => "thdash",
        "THICK_LONG_DASH" => "thldash",
        "THICK_DOT" => "thd",
        "THICK_DASH_DOT" => "thdashd",
        "THICK_DASH_DOT_DOT" => "thdashdd",
        "THICK_WAVE" => 'hwave',
        "DOUBLE_WAVE" => 'uldbwave'
      },
      "to_rtf" => lambda do |value, document|
        return if value.nil?
        case value
        when TrueClass
          '\ul'
        when FalseClass
          '\ulnone'
        when String
          "\\ul#{value}"
        end # case
      end
    },
    "uppercase" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\caps' : '\caps0') unless value.nil? }
    },
    "superscript" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\super' : '\super0') unless value.nil? }
    },
    "subscript" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\sub' : '\sub0') unless value.nil? }
    },
    "strike" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\strike' : '\strike0') unless value.nil? }
    },
    "emboss" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\embo' : '\embo0') unless value.nil? }
    },
    "imprint" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\impr' : '\impr0') unless value.nil? }
    },
    "outline" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\outl' : '\outl0') unless value.nil? }
    },
    "text_hidden" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? '\v' : '\v0') unless value.nil? }
    },
    "kerning" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value.is_a?(Integer) ? "\\kerning#{value}" : '\kerning0') unless value.nil? }
    },
    # non-toggable attributes
    "character_spacing_offset" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2quarterpt(value) },
      "to_rtf" => lambda{ |value, document| "\\expnd#{value}" unless value.nil? }
    },
    "foreground_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cf#{document.colours.index(value)}" unless value.nil? }
    },
    "background_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cb#{document.colours.index(value)}" unless value.nil? }
    },
    "underline_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\ulc#{document.colours.index(value)}" unless value.nil? }
    },
    "highlight_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\highlight#{document.colours.index(value)}" unless value.nil? }
    },
    "font" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Font) ? value : RRTF::Font.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\f#{document.fonts.index(value)}" unless value.nil? }
    },
    "font_size" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2halfpt(value) },
      "to_rtf" => lambda{ |value, document| "\\fs#{value}" unless value.nil? }
    }
  }.freeze

  # Generates attribute accessors for all character attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      CHARACTER_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes character formatting attributes.
  # @note The RTF specification states the "highlight_color" attribute can not
  #   be applied to a style definition in a stylesheet.
  #
  # @param [Hash] options the character formatting options.
  # @option options [Boolean] "bold" (nil) enable or disable bold (nil to remain same).
  # @option options [Boolean] "italic" (nil) enable or disable italic (nil to remain same).
  # @option options [Boolean, String] "underline" (nil) enable or disable underline (nil to remain same); can also be a string (see {CharacterFormatting::CHARACTER_ATTRIBUTES}).
  # @option options [Boolean] "uppercase" (nil) enable or disable all caps (nil to remain same).
  # @option options [Boolean] "superscript" (nil) enable or disable superscript (nil to remain same).
  # @option options [Boolean] "subscript" (nil) enable or disable subscript (nil to remain same).
  # @option options [Boolean] "strike" (nil) enable or disable single line-through (nil to remain same).
  # @option options [Boolean] "emboss" (nil) enable or disable emboss (nil to remain same).
  # @option options [Boolean] "imprint" (nil) enable or disable imprint (nil to remain same).
  # @option options [Boolean] "outline" (nil) enable or disable outline (nil to remain same).
  # @option options [Boolean] "text_hidden" (nil) enable or disable hidden (nil to remain same).
  # @option options [Boolean, Integer] "kerning" (nil) enable or disable kerning (nil to remain same); to enable specify the font size in half-points above which kerining will be applied.
  # @option options [Integer] "character_spacing_offset" (nil) quarter points by which to expand or compress character spacing (negative for compress).
  # @option options [String, Colour] "foreground_color" (nil) colour to apply to the foreground (text); see {Colour.from_string} for string format.
  # @option options [String, Colour] "background_color" (nil) colour to apply to the background; see {Colour.from_string} for string format.
  # @option options [String, Colour] "underline_color" (nil) colour to apply to the underline; see {Colour.from_string} for string format.
  # @option options [String, Colour] "highlight_color" (nil) colour with which to highlight text.
  # @option options [String, Font] "font" (nil) font to apply to text; see {Font.from_string} for string format.
  # @option options [Integer] "font_size" (nil) font size in half-points.
  def initialize_character_formatting(options = {})
    # load default attribute values
    CHARACTER_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_character_formatting_from_hashmap(options)
  end

  # Sets character formatting attributes according to the supplied hashmap.
  # @see #initialize_character_formatting
  def set_character_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(CHARACTER_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if CHARACTER_ATTRIBUTES[attribute].has_key?("from_user")
        value = CHARACTER_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif CHARACTER_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = CHARACTER_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied character formatting.
  # @note To generate correct RTF control words for colours and fonts, a
  #  document object must be provided to this method so that colour and font
  #  indicies may be found in the document's colour and font tables, respectively.
  #
  # @param [Document] document the document for which the RTF is to be generated.
  def character_formatting_to_rtf(document = nil)
     text = StringIO.new

     # accumulate RTF representations of attributes
     CHARACTER_ATTRIBUTES.each do |key, options|
       if options.has_key?("to_rtf")
         rtf = options["to_rtf"].call(send(key), document)
         text << rtf unless rtf.nil?
       end # if
     end # each

     text.string
  end
end # module CharacterFormatting

# Paragraph formatting attributes and methods shared between style types.
# @author Wesley Hileman
# @since 0.0.2
module RRTF::ParagraphFormatting
  # Formatting attributes that can be applied to any paragraph in an RTF document.
  # @return [Hash<String, Hash>] a hash mapping each attribute to a hash that
  #  describes (1) the attribute's default value, (2) how to parse the attribute
  #  from the user, and (3) how to convert the attribute to an RTF sequence.
  PARAGRAPH_ATTRIBUTES = {
    "justification" => {
      "default" => "l",
      "dictionary" => {
        "LEFT" => "l",
        "RIGHT" => "r",
        "CENTER" => "c",
        "CENTRE" => "c",
        "FULL" => "j"
      },
      "to_rtf" => lambda{ |value, document| "\\q#{value}" }
    },
    "left_indent" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\li#{value}" unless value.nil? }
    },
    "right_indent" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\ri#{value}" unless value.nil? }
    },
    "first_line_indent" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\fi#{value}" unless value.nil? }
    },
    "space_before" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\sb#{value}" unless value.nil? }
    },
    "space_after" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\sa#{value}" unless value.nil? }
    },
    "line_spacing" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\sl#{value}" unless value.nil? }
    },
    "widow_orphan_ctl" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? "\\widctlpar" : "\\nowidctlpar") unless value.nil? }
    },
    "no_break" => {
      "default" => false,
      "to_rtf" => lambda{ |value, document| "\\keep" if value }
    },
    "no_break_with_next" => {
      "default" => false,
      "to_rtf" => lambda{ |value, document| "\\keepn" if value }
    },
    "hyphenate" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? "\\hyphpar" : "\\hyphpar0") unless value.nil? }
    },
    "paragraph_flow" => {
      "default" => 'ltr',
      "dictionary" => {
        "LEFT_TO_RIGHT" => 'ltr',
        "RIGHT_TO_LEFT" => 'rtl'
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}par" unless value.nil? }
    },
    "border" => {
      "default" => nil,
      "from_user" => lambda do |value|
        case value
        when Array
          value.collect do |b|
            case b
            when Hash
              RRTF::BorderStyle.new(b)
            when RRTF::BorderStyle
              b
            else
              RRTF::RTFError.fire("Invalid border '#{b}'.")
            end # case
          end # collect
        when Hash
          [RRTF::BorderStyle.new(value)]
        when RRTF::BorderStyle
          [value]
        else
          RRTF::RTFError.fire("Invalid border '#{value}'.")
        end # case
      end,
      "to_rtf" => lambda{ |value, document| value.collect{ |border| border.rtf_formatting(document) }.join(' ') unless value.nil? }
    },
    "position" => {
      "default" => nil,
      "from_user" => lambda do |value|
        case value
        when Hash
          RRTF::PositionStyle.new(value)
        when PositionStyle
          value
        else
          RRTF::RTFError.fire("Invalid position '#{value}'.")
        end # case
      end,
      "to_rtf" => lambda{ |value, document| value.rtf_formatting(document) unless value.nil? }
    },
    "shading" => {
      "default" => nil,
      "from_user" => lambda do |value|
        case value
        when Hash
          RRTF::ShadingStyle.new(value)
        when ShadingStyle
          value
        else
          RRTF::RTFError.fire("Invalid shading '#{value}'.")
        end # case
      end,
      "to_rtf" => lambda{ |value, document| value.rtf_formatting(document) unless value.nil? }
    },
    "tabs" => {
      "default" => nil,
      "from_user" => lambda do |value|
        case value
        when Array
          value.collect do |t|
            case t
            when Hash
              RRTF::TabStyle.new(t)
            when RRTF::TabStyle
              t
            else
              RRTF::RTFError.fire("Invalid tab '#{t}'.")
            end # case
          end # collect
        when Hash
          [RRTF::TabStyle.new(value)]
        when RRTF::TabStyle
          [value]
        else
          RRTF::RTFError.fire("Invalid border '#{value}'.")
        end # case
      end,
      "to_rtf" => lambda do |value, document|
        value.collect{ |tab| tab.rtf_formatting }.join(' ') unless value.nil?
      end
    }
  }.freeze

  # Generates attribute accessors for all paragraph attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      PARAGRAPH_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes paragraph formatting attributes.
  #
  # @param [Hash] options the paragraph formatting options.
  # @option options [String] "justification" ('LEFT') the paragraph justification ('LEFT', 'CENTER'/'CENTRE', 'RIGHT', or 'FULL').
  # @option options [Integer] "left_indent" (nil) the left indent of the paragraph (twentieth points).
  # @option options [Integer] "right_indent" (nil) the right indent of the paragraph (twentieth points).
  # @option options [Integer] "first_line_indent" (nil) the first line indent of the paragraph (twentieth points).
  # @option options [Integer] "space_before" (nil) the space before the paragraph (twentieth points).
  # @option options [Integer] "space_after" (nil) the space after the paragraph (twentieth points).
  # @option options [Integer] "line_spacing" (nil) the line spacing in the paragraph (twentieth points).
  # @option options [Boolean] "widow_orphan_ctl" (nil) enable or disable widow-and-orphan control.
  # @option options [Boolean] "no_break" (nil) when true, tries to keep the paragraph on the same page (i.e. without breaking).
  # @option options [Boolean] "no_break_with_next" (nil) when true, tries to keep the paragraph with the next paragraph on the same page (i.e. without breaking).
  # @option options [Boolean] "hyphenate" (nil) enable or disable hyphenation for the paragraph.
  # @option options [String] "paragraph_flow" ('LEFT_TO_RIGHT') the text flow direction in the paragraph ('LEFT_TO_RIGHT' or 'RIGHT_TO_LEFT').
  # @option options [Array<Hash, BorderStyle>, Hash, BorderStyle] "border" (nil) the border style(s) to be applied to the paragraph (see {BorderFormatting#initialize_border_formatting}).
  def initialize_paragraph_formatting(options = {})
    # load default attribute values
    PARAGRAPH_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_paragraph_formatting_from_hashmap(options)
  end

  # Sets paragraph formatting attributes according to the supplied hashmap.
  # @see #initialize_document_formatting
  def set_paragraph_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(PARAGRAPH_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if PARAGRAPH_ATTRIBUTES[attribute].has_key?("from_user")
        value = PARAGRAPH_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif PARAGRAPH_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = PARAGRAPH_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied paragraph formatting.
  # @note To generate correct RTF control words for colours and fonts, a
  #  document object must be provided to this method so that colour and font
  #  indicies may be found in the document's colour and font tables, respectively.
  #
  # @param [Document] document the document for which the RTF is to be generated.
  def paragraph_formatting_to_rtf(document)
    text = StringIO.new

    # accumulate RTF representations of paragraph attributes
    PARAGRAPH_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key), document)
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end # module ParagraphFormatting

# Paragraph, table, and image border formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::BorderFormatting
  # Formatting attributes that can be applied to borders of paragraphs, tables, & images.
  # @note The "sides" attribute must appear at the top of this hash so that
  #   {#border_formatting_to_rtf} generates correct RTF (borders are initiated by the "sides"
  #   attribute in the RTF spec).
  # @note The "line_type" attribute must appear second in this hash so that
  #   {#border_formatting_to_rtf} generates correct RTF.
  BORDER_ATTRIBUTES = {
    "sides" => {
      "default" => "box",
      "dictionary" => {
        "ALL" => "box",
        "LEFT" => "brdrl",
        "RIGHT" => "brdrr",
        "TOP" => "brdrt",
        "BOTTOM" => "brdrb"
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "line_type" => {
      "default" => "brdrs",
      "dictionary" => {
        "SINGLE" => "brdrs",
        "THICK" => "brdrth",
        "DOUBLE" => "brdrdb",
        "DOT" => "brdrdot",
        "DASH" => "brdrdash",
        "HAIRLINE" => "brdrhair"
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "width" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\brdrw#{value}" unless value.nil? }
    },
    "spacing" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value, document| "\\brsp#{value}" unless value.nil? }
    },
    "color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\brdrcf#{document.colours.index(value)}" unless value.nil? }
    }
  }.freeze

  # Generates attribute accessors for all paragraph attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      BORDER_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes border formatting attributes.
  #
  # @param [Hash] options the border formatting options.
  # @option options [String] "sides" ('ALL') the sides to which the border applied ("ALL", "LEFT", "RIGHT", "TOP", or "BOTTOM").
  # @option options [String] "line_type" ('SINGLE') the border line type ("SINGLE", "THICK", "DOUBLE", "DOT", "DASH", or "HAIRLINE").
  # @option options [String] "width" (nil) the width of the the border line in twips (can be a string, see {Utilities.value2twips}).
  # @option options [String] "spacing" (nil) the spacing between the border and paragraph content in twips (can be a string, see {Utilities.value2twips}).
  # @option options [String, Colour] "color" (nil) the color of the the border line (can be a string, see {Colour.from_string}).
  def initialize_border_formatting(options = {})
    # load default attribute values
    BORDER_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_border_formatting_from_hashmap(options)
  end

  # Sets paragraph formatting attributes according to the supplied hashmap.
  # @see #initialize_border_formatting
  def set_border_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(BORDER_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if BORDER_ATTRIBUTES[attribute].has_key?("from_user")
        value = BORDER_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif BORDER_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = BORDER_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied border formatting.
  # @note To generate correct RTF control words for colours and fonts, a
  #  document object must be provided to this method so that colour and font
  #  indicies may be found in the document's colour and font tables, respectively.
  #
  # @param [Document] document the document for which the RTF is to be generated.
  def border_formatting_to_rtf(document)
    text = StringIO.new

    # accumulate RTF representations of paragraph attributes
    BORDER_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key), document)
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end

# Paragraph absolute positioning formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::PositionFormatting
  # Formatting attributes that can be applied to position paragraphs as frames.
  POSITION_ATTRIBUTES = {
    "size" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Page::Size.new(value) },
      "to_rtf" => lambda{ |value, document| "\\absw#{value.width}\\absh#{value.height}" unless value.nil? }
    },
    "horizontal_reference" => {
      "default" => nil,
      "dictionary" => {
        "PAGE" => "phpg",
        "MARGIN" => "phmrg",
        "COLUMN" => "phcol"
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "vertical_reference" => {
      "default" => nil,
      "dictionary" => {
        "PAGE" => "pvpg",
        "MARGIN" => "pvmrg",
        "PARAGRAPH" => "pvpara"
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "horizontal_position" => {
      "default" => nil,
      "dictionary" => {
        "CENTER" => "posxc",
        "LEFT" => "posxl",
        "RIGHT" => "posxr"
      },
      "from_user" => lambda do |value|
        return nil if value.nil?
        if value.is_a?(String) && value =~ /^([A-Z]+)$/
          POSITION_ATTRIBUTES["horizontal_position"]["dictionary"][value]
        else
          "posx#{RRTF::Utilities.value2twips(value)}"
        end
      end,
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "vertical_position" => {
      "default" => nil,
      "dictionary" => {
        "CENTER" => "posyc",
        "TOP" => "posyt",
        "BOTTOM" => "posyb"
      },
      "from_user" => lambda do |value|
        return nil if value.nil?
        if value.is_a?(String) && value =~ /^([A-Z]+)$/
          POSITION_ATTRIBUTES["vertical_position"]["dictionary"][value]
        else
          "posy#{RRTF::Utilities.value2twips(value)}"
        end
      end,
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "text_wrap" => {
      "default" => nil,
      "dictionary" => {
        "NONE" => "nowrap",
        "DEFAULT" => "wrapdefault",
        "AROUND" => "wraparound",
        "TIGHT" => "wraptight",
        "THROUGH" => "wrapthrough"
      },
      "to_rtf" => lambda{ |value, document| "\\#{value}" unless value.nil? }
    },
    "drop_cap_lines" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\dropcapli#{value}" unless value.nil? }
    },
    "drop_cap_type" => {
      "default" => nil,
      "dictionary" => {
        "IN_TEXT" => 1,
        "IN_MARGIN" => 2
      },
      "to_rtf" => lambda{ |value, document| "\\dropcapt#{value}" unless value.nil? }
    },
    "lock_anchor" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| (value ? "\\abslock0" : "\\abslock1") unless value.nil? }
    }
  }.freeze

  # Generates attribute accessors for all position attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for position attributes
    base.class_eval do
      POSITION_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes position formatting attributes.
  #
  # @param [Hash] options the border formatting options.
  # @option options [String] "sides" ('ALL') the sides to which the border applied ("ALL", "LEFT", "RIGHT", "TOP", or "BOTTOM").
  def initialize_position_formatting(options = {})
    # load default attribute values
    POSITION_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_position_formatting_from_hashmap(options)
  end

  # Sets formatting attributes according to the supplied hashmap.
  # @see #initialize_position_formatting
  def set_position_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(POSITION_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if POSITION_ATTRIBUTES[attribute].has_key?("from_user")
        value = POSITION_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif POSITION_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = POSITION_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied position formatting.
  # @note To generate correct RTF control words for colours and fonts, a
  #  document object must be provided to this method so that colour and font
  #  indicies may be found in the document's colour and font tables, respectively.
  #
  # @param [Document] document the document for which the RTF is to be generated.
  def position_formatting_to_rtf(document)
    text = StringIO.new

    # accumulate RTF representations of paragraph attributes
    POSITION_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key), document)
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end

# Paragraph shading formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::ShadingFormatting
  # Formatting attributes that can be applied to shade the background
  # of paragraphs.
  SHADING_ATTRIBUTES = {
    "opacity" => {
      "default" => 100,
      "from_user" => lambda{ |value| RRTF::Utilities.value2hunpercent(value) },
      "to_rtf" => lambda{ |value, document| "\\shading#{value}" unless value.nil? }
    },
    "foreground_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cfpat#{document.colours.index(value)}" unless value.nil? }
    },
    "background_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Colour) ? value : RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cbpat#{document.colours.index(value)}" unless value.nil? }
    }
  }.freeze

  # Generates attribute accessors for all position attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for position attributes
    base.class_eval do
      SHADING_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes position formatting attributes.
  #
  # @param [Hash] options the border formatting options.
  # @option options [String] "sides" ('ALL') the sides to which the border applied ("ALL", "LEFT", "RIGHT", "TOP", or "BOTTOM").
  def initialize_shading_formatting(options = {})
    # load default attribute values
    SHADING_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_shading_formatting_from_hashmap(options)
  end

  # Sets formatting attributes according to the supplied hashmap.
  # @see #initialize_shading_formatting
  def set_shading_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(SHADING_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if SHADING_ATTRIBUTES[attribute].has_key?("from_user")
        value = SHADING_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif SHADING_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = SHADING_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied position formatting.
  # @note To generate correct RTF control words for colours and fonts, a
  #  document object must be provided to this method so that colour and font
  #  indicies may be found in the document's colour and font tables, respectively.
  #
  # @param [Document] document the document for which the RTF is to be generated.
  def shading_formatting_to_rtf(document)
    text = StringIO.new

    # accumulate RTF representations of paragraph attributes
    SHADING_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key), document)
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end

# Document formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::DocumentFormatting
  # Formatting attributes that can be applied to an RTF document.
  # @return [Hash<String, Hash>] a hash mapping each attribute to a hash that
  #  describes (1) the attribute's default value, (2) how to parse the attribute
  #  from the user, and (3) how to convert the attribute to an RTF sequence.
  DOCUMENT_ATTRIBUTES = {
    "facing_pages" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\facingp" if value }
    },
    "mirror_margins" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\margmirror" if value }
    },
    "widow_orphan_ctl" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\widowctl" if value }
    },
    "tab_width" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value| "\\deftab#{value}" unless value.nil? }
    },
    "hyphenation_width" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value| "\\hyphhotz#{value}" unless value.nil? }
    },
    "max_consecutive_hyphenation" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\hyphconsec#{value}" unless value.nil? }
    },
    "hyphenate" => {
      "default" => true,
      "to_rtf" => lambda{ |value| (value ? "\\hyphauto1" : "\\hyphauto0") unless value.nil? }
    }
  }.freeze

  # Generates attribute accessors for all document attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for document attributes
    base.class_eval do
      DOCUMENT_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes document formatting attributes.
  #
  # @param [Hash] options the document formatting options.
  # @option options [Boolean] "facing_pages" (nil) whether or not to enable facing pages in the document.
  # @option options [Boolean] "mirror_margins" (nil) whether or not to enable mirrored margins (when facing pages is enabled) in the document.
  # @option options [Boolean] "widow_orphan_ctl" (nil) whether or not to enable widow and orphan control for the document.
  # @option options [String] "tab_width" (nil) the default tab width for the document (specify a string, see {Utilities.value2twips}).
  # @option options [String] "hyphenation_width" (nil) the space from the right margin in which hyphenation occurs in the document (specify a string, see {Utilities.value2twips}).
  # @option options [Integer] "max_consecutive_hyphenation" (nil) the maximum number of consecutive hyphentated lines allowed in the document.
  # @option options [Boolean] "hyphenate" (nil) enable or disable hyphenation in the document.
  def initialize_document_formatting(options = {})
    # load default attribute values
    DOCUMENT_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_document_formatting_from_hashmap(options)
  end

  # Sets document formatting attributes according to the supplied hashmap.
  # @see #initialize_document_formatting
  def set_document_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(DOCUMENT_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if DOCUMENT_ATTRIBUTES[attribute].has_key?("from_user")
        value = DOCUMENT_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif DOCUMENT_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = DOCUMENT_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied document formatting.
  #
  # @return [String] RTF string.
  def document_formatting_to_rtf
    text = StringIO.new

    # accumulate RTF representations of document attributes
    DOCUMENT_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key))
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end # module DocumentFormatting

# Section formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::SectionFormatting
  # Formatting attributes that can be applied to an RTF document section.
  # @return [Hash<String, Hash>] a hash mapping each attribute to a hash that
  #  describes (1) the attribute's default value, (2) how to parse the attribute
  #  from the user, and (3) how to convert the attribute to an RTF sequence.
  SECTION_ATTRIBUTES = {
    "columns" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\cols#{value}" unless value.nil? }
    },
    "column_spacing" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda{ |value| "\\colsx#{value}" unless value.nil? }
    },
    "mirror_margins" => {
      "default" => nil,
      "to_rtf" => lambda{ |value| "\\margmirrorsxn" if value }
    }
  }.freeze

  # Generates attribute accessors for all section attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for document attributes
    base.class_eval do
      SECTION_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes section formatting attributes.
  #
  # @param [Hash] options the section formatting options.
  # @option options [Integer] "columns" (nil) the number of columns in the section.
  # @option options [String, Integer] "column_spacing" (nil) the column spacing in twips (can also be a string, see {Utilities.value2twips}).
  # @option options [Boolean] "mirror_margins" (nil) whether or not to enable mirrored margins (when facing pages is enabled) in the document.
  def initialize_section_formatting(options = {})
    # load default attribute values
    SECTION_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_section_formatting_from_hashmap(options)
  end

  # Sets section formatting attributes according to the supplied hashmap.
  # @see #initialize_section_formatting
  def set_section_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(SECTION_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if SECTION_ATTRIBUTES[attribute].has_key?("from_user")
        value = SECTION_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif SECTION_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = SECTION_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied section formatting.
  #
  # @return [String] RTF string.
  def section_formatting_to_rtf
    text = StringIO.new

    # accumulate RTF representations of section attributes
    SECTION_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key))
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end # module SectionFormatting

# Page formatting attributes and methods.
# @author Wesley Hileman
# @since 1.0.0
module RRTF::PageFormatting
  # Formatting attributes that can be applied to an RTF document or a section
  # in a document.
  # @return [Hash<String, Hash>] a hash mapping each attribute to a hash that
  #  describes (1) the attribute's default value, (2) how to parse the attribute
  #  from the user, and (3) how to convert the attribute to an RTF sequence.
  PAGE_ATTRIBUTES = {
    "orientation" => {
      "default" => :portrait,
      "dictionary" => {
        "PORTRAIT" => :portrait,
        "LANDSCAPE" => :landscape
      },
      "to_rtf" => lambda do |value, targ|
        case targ
        when :document
          "\\landscape" if value == :landscape
        when :section
          "\\lndscpsxn" if value == :landscape
        end # case
      end
    },
    "size" => {
      "default" => RRTF::Page::Size.new,
      "from_user" => lambda{ |value| RRTF::Page::Size.new(value) },
      "to_rtf" => lambda do |value, targ|
        case targ
        when :document
          "\\paperw#{value.width}\\paperh#{value.height}"
        when :section
          "\\pgwsxn#{value.width}\\pghsxn#{value.height}"
        end # case
      end
    },
    "margin" => {
      "default" => RRTF::Page::Margin.new,
      "from_user" => lambda{ |value| RRTF::Page::Margin.new(value) },
      "to_rtf" => lambda do |value, targ|
        case targ
        when :document
          "\\margl#{value.left}\\margr#{value.right}\\margt#{value.top}\\margb#{value.bottom}"
        when :section
          "\\marglsxn#{value.left}\\margrsnx#{value.right}\\margtsxn#{value.top}\\margbsnx#{value.bottom}"
        end # case
      end
    },
    "gutter" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Utilities.value2twips(value) },
      "to_rtf" => lambda do |value, targ|
        case targ
        when :document
          "\\gutter#{value}" unless value.nil?
        when :section
          "\\guttersxn#{value}" unless value.nil?
        end # case
      end
    }
  }.freeze

  PAGE_FORMATTING_TARGET_DICTIONARY = {
    "DOCUMENT"      => :document,
    "SECTION"       => :section
  }.freeze

  attr_accessor :target

  # Generates attribute accessors for all page attributes when the module
  # is included in another module or class.
  def self.included(base)
    # define accessors in base for document attributes
    base.class_eval do
      PAGE_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes page formatting attributes.
  # @note The behavior of the "gutter" option changes with the document
  #   "facing_pages" setting.
  #
  # @param [Hash] options the document formatting options.
  # @option options [String] "orientation" ("PORTRAIT") the orientation of the paper ("PORTRAIT" or "LANDSCAPE").
  # @option options [String, Page::Size] "size" (Page::Size.new) the size of the paper (object or string; see {Page::Size#initialize}).
  # @option options [String, Page::Margin] "margin" (Page::Margin.new) the paper margin (object or string; see {Page::Margin#initialize}).
  # @option options [String] "gutter" (nil) the page gutter width (specify a string, see {Utilities.value2twips}).
  def initialize_page_formatting(options = {}, target = "DOCUMENT")
    @target = PAGE_FORMATTING_TARGET_DICTIONARY[target]

    # load default attribute values
    PAGE_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_page_formatting_from_hashmap(options)
  end

  # Sets document formatting attributes according to the supplied hashmap.
  # @see #initialize_page_formatting
  def set_page_formatting_from_hashmap(hash)
    hash.each do |attribute, value|
      # skip unreconized attributes
      next unless(PAGE_ATTRIBUTES.keys.include?(attribute))
      # preprocess value if nessesary
      if PAGE_ATTRIBUTES[attribute].has_key?("from_user")
        value = PAGE_ATTRIBUTES[attribute]["from_user"].call(value)
      elsif PAGE_ATTRIBUTES[attribute].has_key?("dictionary") && value.is_a?(String)
        value = PAGE_ATTRIBUTES[attribute]["dictionary"][value]
      end # if
      # set attribute value
      send("#{attribute}=", value)
    end # each
  end

  # Generates an RTF string representing all applied page formatting.
  #
  # @return [String] RTF string.
  def page_formatting_to_rtf
    text = StringIO.new

    # accumulate RTF representations of page attributes
    PAGE_ATTRIBUTES.each do |key, options|
      if options.has_key?("to_rtf")
        rtf = options["to_rtf"].call(send(key), @target)
        text << rtf unless rtf.nil?
      end # if
    end # each

    text.string
  end
end
