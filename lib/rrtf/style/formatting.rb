require 'stringio'

# Encapsulates all character formatting methods shared between style types.
# @author Wesley Hileman
module RRTF::CharacterFormatting
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
    "font" => {
      "default" => nil,
      "from_user" => lambda{ |value| value.is_a?(RRTF::Font) ? value : RRTF::Font.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\f#{document.fonts.index(value)}" unless value.nil? }
    },
    "font_size" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\fs#{value}" unless value.nil? }
    }
  }.freeze

  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      CHARACTER_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

  # Initializes character formatting attributes.
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
  # @option options [String, Colour] "background_color" (nil) colour to apply to the background (highlight); see {Colour.from_string} for string format.
  # @option options [String, Colour] "underline_color" (nil) colour to apply to the underline; see {Colour.from_string} for string format.
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

  def push_colours(colours)
    colours << foreground_color unless foreground_color.nil?
    colours << background_color unless background_color.nil?
    colours << underline_color unless underline_color.nil?
  end

  def push_fonts(fonts)
    fonts << font unless font.nil?
  end

  def character_formatting_to_rtf(document)
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

# Encapsulates all paragraph formatting methods shared between style types.
# @author Wesley Hileman
module RRTF::ParagraphFormatting
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
      "to_rtf" => lambda{ |value, document| "\\li#{value}" unless value.nil? }
    },
    "right_indent" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\ri#{value}" unless value.nil? }
    },
    "first_line_indent" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\fi#{value}" unless value.nil? }
    },
    "space_before" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\sb#{value}" unless value.nil? }
    },
    "space_after" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\sa#{value}" unless value.nil? }
    },
    "line_spacing" => {
      "default" => nil,
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
    }
  }.freeze

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
  def initialize_paragraph_formatting(options = {})
    # load default attribute values
    PARAGRAPH_ATTRIBUTES.each do |key, options|
      send("#{key}=", options["default"])
    end # each
    # overwrite default attribute values with given values
    set_paragraph_formatting_from_hashmap(options)
  end

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
