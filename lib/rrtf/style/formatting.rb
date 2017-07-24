require 'stringio'

# Encapsulates all character formatting methods shared between style types
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
    "hidden" => {
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
      "from_user" => lambda{ |value| RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cf#{document.colours.index(value)}" unless value.nil? }
    },
    "background_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\cb#{document.colours.index(value)}" unless value.nil? }
    },
    "underline_color" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Colour.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\ulc#{document.colours.index(value)}" unless value.nil? }
    },
    "font" => {
      "default" => nil,
      "from_user" => lambda{ |value| RRTF::Font.from_string(value) },
      "to_rtf" => lambda{ |value, document| "\\f#{document.fonts.index(value)}" unless value.nil? }
    },
    "font_size" => {
      "default" => nil,
      "to_rtf" => lambda{ |value, document| "\\fs#{value}" unless value.nil? }
    }
  }

  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      CHARACTER_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

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
       text << options["to_rtf"].call(send(key), document) if options.has_key?("to_rtf")
     end # each

     text.string
  end
end # module CharacterFormatting

# Encapsulates all paragraph formatting methods shared between style types
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
  }

  def self.included(base)
    # define accessors in base for paragraph attributes
    base.class_eval do
      PARAGRAPH_ATTRIBUTES.each do |key, options|
        attr_accessor :"#{key}"
      end # each
    end # class_eval
  end

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
      text << options["to_rtf"].call(send(key), document) if options.has_key?("to_rtf")
    end # each

    text.string
  end
end # module ParagraphFormatting
