#!/usr/bin/env ruby

require 'stringio'

module RRTF
  # Encapsulates all character formatting methods shared between style types
  module CharacterFormatting
    attr_accessor :bold, :italic, :underline, :superscript, :capitalise,
                  :strike, :subscript, :hidden, :foreground, :background,
                  :font, :font_size

    def initialize_character_formatting
      @bold        = nil
      @italic      = nil
      @underline   = nil
      @superscript = nil
      @capitalise  = nil
      @strike      = nil
      @subscript   = nil
      @hidden      = false
      @foreground  = nil
      @background  = nil
      @font        = nil
      @font_size   = nil
    end

    def set_character_formatting_from_hashmap(hash)
      hash.each do |attribute, value|
        next unless(['bold', 'italic', 'underline', 'superscript', 'subscript',
          'capitalise', 'capitalize', 'strike', 'subscript', 'hidden',
          'foreground', 'background', 'font', 'font_size'].include?(attribute))

        case attribute
        when 'foreground', 'background'
          value = Colour.from_string(value)
        when 'font'
          value = Font.from_string(value)
        end # case

        send(:"#{attribute}=", value)
      end # each
    end

    def push_colours(colours)
      colours << foreground unless foreground.nil?
      colours << background unless background.nil?
    end

    def push_fonts(fonts)
      fonts << font unless font.nil?
    end

    def character_formatting_to_rtf(fonts, colours)
       text = StringIO.new

       text << (@bold ?        '\b'      : '\b0')       unless @bold.nil?
       text << (@italic ?      '\i'      : '\i0')       unless @italic.nil?
       text << (@underline ?   '\ul'     : '\ul0')      unless @underline.nil?
       text << (@superscript ? '\super'  : '\super0')   unless @superscript.nil?
       text << (@subscript ?   '\sub'    : '\sub0')     unless @subscript.nil?
       text << (@capitalise ?  '\caps'   : '\caps0')    unless @capitalise.nil?
       text << (@strike ?      '\strike' : '\strike0')  unless @strike.nil?
       text << '\v' if @hidden
       text << "\\cf#{colours.index(@foreground)}" if @foreground != nil
       text << "\\cb#{colours.index(@background)}" if @background != nil
       text << "\\f#{fonts.index(@font)}" if @font != nil
       text << "\\fs#{@font_size.to_i}" if @font_size != nil
       text << '\rtlch' if @flow == Style::RIGHT_TO_LEFT

       text.string
    end

    alias :capitalize :capitalise
    alias :capitalize= :capitalise=
  end # module CharacterFormatting

  # Encapsulates all paragraph formatting methods shared between style types
  module ParagraphFormatting
    # Justification constants
    LEFT_JUSTIFY    = :ql
    RIGHT_JUSTIFY   = :qr
    CENTER_JUSTIFY  = :qc
    CENTRE_JUSTIFY  = :qc
    FULL_JUSTIFY    = :qj

    attr_accessor :justification, :left_indent, :right_indent,
                  :first_line_indent, :space_before, :space_after,
                  :line_spacing

    def initialize_paragraph_formatting(base)
      @justification     = base.nil? ? LEFT_JUSTIFY : base.justification
      @left_indent       = base.nil? ? nil : base.left_indent
      @right_indent      = base.nil? ? nil : base.right_indent
      @first_line_indent = base.nil? ? nil : base.first_line_indent
      @space_before      = base.nil? ? nil : base.space_before
      @space_after       = base.nil? ? nil : base.space_after
      @line_spacing      = base.nil? ? nil : base.line_spacing
    end

    def set_paragraph_formatting_from_hashmap(hash)
      hash.each do |attribute, value|
        next unless(['justification', 'left_indent', 'right_indent',
          'first_line_indent', 'space_before', 'space_after',
          'line_spacing'].include?(attribute))

        case attribute
        when 'justification'
          value = value.constantize
        end # case

        send(:"#{attribute}=", value)
      end # each
    end

    def paragraph_formatting_to_rtf(fonts, colours)
      text = StringIO.new

      text << "\\#{@justification.id2name}"
      text << "\\li#{@left_indent}"        unless @left_indent.nil?
      text << "\\ri#{@right_indent}"       unless @right_indent.nil?
      text << "\\fi#{@first_line_indent}"  unless @first_line_indent.nil?
      text << "\\sb#{@space_before}"       unless @space_before.nil?
      text << "\\sa#{@space_after}"        unless @space_after.nil?
      text << "\\sl#{@line_spacing}"       unless @line_spacing.nil?
      text << '\rtlpar' if @flow == Style::RIGHT_TO_LEFT

      text.string
    end
  end # module ParagraphFormatting

   # This is a parent class that all style classes will derive from.
   class Style
      # A definition for a character flow setting.
      LEFT_TO_RIGHT                              = :rtl

      # A definition for a character flow setting.
      RIGHT_TO_LEFT                              = :ltr

      attr_accessor :handle, :name, :id, :priority, :flow

      # Constructor for the style class.
      #
      # ===== Parameters
      # options:: A hashmap of options for the style. Used only in stylesheet.
      #   name::        Human-readable name for the style DEFAULT nil
      #   id::          ID for the style (for use in code) DEFAULT nil
      #   handle::      A 16-bit integer that identifies the style in a document
      #                 DEFAULT nil
      #   flow::        The character flow (Style::LEFT_TO_RIGHT or Style::RIGHT_TO_LEFT)
      #                 DEFAULT LEFT_TO_RIGHT
      #   primary::     A Boolean indicating whether or not this style is a
      #                 primary or "quick" style
      #   additive::    A Boolean indicating whether or not this style is
      #                 additive DEFAULT false
      def initialize(options = {})
        # load default options
        options = {
          :name => nil,
          :id => nil,
          :handle => nil,
          :priority => nil,
          :flow => LEFT_TO_RIGHT,
          :primary => false,
          :additive => false
        }.merge(options)

        @handle = options.delete(:handle)
        @name = options.delete(:name)
        @id = options.delete(:id)
        @priority = options.delete(:priority)
        @flow = options.delete(:flow)
        # additional options
        @options = options
      end

      # Constructs an RTF identifier for the style.
      # (override in derived classes as needed)
      def styledef
        nil
      end

      def stylename
        name
      end

      # Constructs the RTF formatting representing the style.
      # (override in derived classes as needed)
      def to_rtf(fonts, colours)
        nil
      end

      # This method retrieves the command prefix text associated with a Style
      # object. This method always returns nil and should be overridden by
      # derived classes as needed.
      #
      # ==== Parameters
      # fonts::    A reference to the document fonts table. May be nil if no
      #            fonts are used.
      # colours::  A reference to the document colour table. May be nil if no
      #            colours are used.
      def prefix(fonts, colours)
         nil
      end

      # This method retrieves the command suffix text associated with a Style
      # object. This method always returns nil and should be overridden by
      # derived classes as needed.
      #
      # ==== Parameters
      # fonts::    A reference to the document fonts table. May be nil if no
      #            fonts are used.
      # colours::  A reference to the document colour table. May be nil if no
      #            colours are used.
      def suffix(fonts, colours)
         nil
      end

      # Used to determine if the style applies to characters. This method always
      # returns false and should be overridden by derived classes as needed.
      def is_character_style?
         false
      end

      # Used to determine if the style applies to paragraphs. This method always
      # returns false and should be overridden by derived classes as needed.
      def is_paragraph_style?
         false
      end

      # Used to determine if the style applies to documents. This method always
      # returns false and should be overridden by derived classes as needed.
      def is_document_style?
         false
      end

      # Used to determine if the style applies to tables. This method always
      # returns false and should be overridden by derived classes as needed.
      def is_table_style?
         false
      end
   end # End of the style class.


   # This class represents a character style for an RTF document.
   class CharacterStyle < Style
     include CharacterFormatting

     def self.from_hashmap(hash)
       name = hash.delete("name")
       id = hash.delete("id")
       primary = hash.key?("primary") ? hash.delete("primary") : false
       additive = hash.key?("additive") ? hash.delete("additive") : false
       style = self.new(:name => name, :id => id, :primary => primary, :additive => additive)
       style.set_character_formatting_from_hashmap(hash)
       style
     end

      # This is the constructor for the CharacterStyle class.
      #
      # ==== Exceptions
      # RTFError::  Generate if the parent style specified is not an instance
      #             of the CharacterStyle class.
      def initialize(options = {})
         super(options)
         initialize_character_formatting()
      end

      # This method overrides the is_character_style? method inherited from the
      # Style class to always return true.
      def is_character_style?
         true
      end

      # Converts the stylesheet character style into its RTF representation
      # (for stylesheet)
      #
      # ==== Parameters
      # fonts::    A reference to a FontTable containing any fonts used by the
      #            style (may be nil if no fonts used).
      # colours::  A reference to a ColourTable containing any colours used by
      #            the style (may be nil if no colours used).
      def to_rtf(fonts, colours)
        rtf = StringIO.new

        rtf << "{\\*\\cs#{handle} "
        rtf << "#{rtf_formatting(fonts, colours)} "
        rtf << "\\additive " if @options[:additive]
        rtf << "\\sqformat " if @options[:primary]
        rtf << "\\spriority#{@priority} " unless @priority.nil?
        rtf << "#{name};}"

        rtf.string
      end

      # This method generates a string containing the prefix associated with a
      # style object.
      #
      # ==== Parameters
      # fonts::    A reference to a FontTable containing any fonts used by the
      #            style (may be nil if no fonts used).
      # colours::  A reference to a ColourTable containing any colours used by
      #            the style (may be nil if no colours used).
      def prefix(fonts, colours)
        text = StringIO.new

        text << "\\cs#{handle} " unless handle.nil?
        text << rtf_formatting(fonts, colours)

        text.string
      end

      def rtf_formatting(fonts, colours)
        character_formatting_to_rtf(fonts, colours)
      end
   end # End of the CharacterStyle class.


   # This class represents a styling for a paragraph within an RTF document.
   # NOTE: Paragraphs can be styled with character commands in addition to
   # paragraph commands, thus this class includes both paragraph & character
   # formatting modules
   class ParagraphStyle < Style
     include ParagraphFormatting
     include CharacterFormatting

     def self.from_hashmap(hash)
       name = hash.delete("name")
       id = hash.delete("id")
       primary = hash.key?("primary") ? hash.delete("primary") : false
       additive = hash.key?("additive") ? hash.delete("additive") : false
       style = self.new(nil, :name => name, :id => id, :primary => primary, :additive => additive)
       style.set_paragraph_formatting_from_hashmap(hash)
       style.set_character_formatting_from_hashmap(hash)
       style
     end

      # This is a constructor for the ParagraphStyle class.
      #
      # ==== Parameters
      # base::  A reference to base object that the new style will inherit its
      #         initial properties from. Defaults to nil.
      def initialize(base = nil, options = {})
         super(options)
         initialize_paragraph_formatting(base)
         initialize_character_formatting()
      end

      # This method overrides the is_paragraph_style? method inherited from the
      # Style class to always return true.
      def is_paragraph_style?
         true
      end

      # Converts the stylesheet paragraph style into its RTF representation
      #
      # ==== Parameters
      # fonts::    A reference to a FontTable containing any fonts used by the
      #            style (may be nil if no fonts used).
      # colours::  A reference to a ColourTable containing any colours used by
      #            the style (may be nil if no colours used).
      def to_rtf(fonts, colours)
        rtf = StringIO.new

        rtf << "{\\s#{handle} "
        rtf << "#{rtf_formatting(fonts, colours)} "
        rtf << "\\additive " if @options[:additive]
        rtf << "\\sqformat " if @options[:primary]
        rtf << "\\spriority#{@priority} " unless @priority.nil?
        rtf << "#{name};}"

        rtf.string
      end

      # This method generates a string containing the prefix associated with a
      # style object.
      #
      # ==== Parameters
      # fonts::    A reference to a FontTable containing any fonts used by the
      #            style (may be nil if no fonts used).
      # colours::  A reference to a ColourTable containing any colours used by
      #            the style (may be nil if no colours used).
      def prefix(fonts, colours)
        text = StringIO.new

        text << "\\s#{handle} " unless handle.nil?
        text << rtf_formatting(fonts, colours)

        text.string
      end

      def rtf_formatting(fonts, colours)
        "#{paragraph_formatting_to_rtf(fonts, colours)} #{character_formatting_to_rtf(fonts, colours)}"
      end
   end # End of the ParagraphStyle class.


   # This class represents styling attributes that are to be applied at the
   # document level.
   class DocumentStyle < Style
      # Definition for a document orientation setting.
      PORTRAIT                                   = :portrait

      # Definition for a document orientation setting.
      LANDSCAPE                                  = :landscape

      # Definition for a default margin setting.
      DEFAULT_LEFT_MARGIN                        = 1800

      # Definition for a default margin setting.
      DEFAULT_RIGHT_MARGIN                       = 1800

      # Definition for a default margin setting.
      DEFAULT_TOP_MARGIN                         = 1440

      # Definition for a default margin setting.
      DEFAULT_BOTTOM_MARGIN                      = 1440

      # stylesheet sorting codes
      STYLESHEET_SORT_NAME       = 0 # stylesheet styles sorted by name
      STYLESHEET_SORT_DEFAULT    = 1 # stylesheet styles sorted by system default
      STYLESHEET_SORT_FONT       = 2 # stylesheet styles sorted by font
      STYLESHEET_SORT_BASEDON    = 3 # stylesheet styles sorted by based-on fonts
      STYLESHEET_SORT_TYPE       = 4 # stylesheet styles sorted by type

      # Attribute accessor.
      attr_reader :paper, :left_margin, :right_margin, :top_margin,
                  :bottom_margin, :gutter, :orientation, :stylesheet_sort

      # Attribute mutator.
      attr_writer :paper, :left_margin, :right_margin, :top_margin,
                  :bottom_margin, :gutter, :orientation, :stylesheet_sort

      # This is a constructor for the DocumentStyle class. This creates a
      # document style with a default paper setting of LETTER and portrait
      # orientation (all other attributes are nil).
      def initialize(options = {})
        # load default options
        options = {
          :paper_size => Paper::LETTER,
          :left_margin => DEFAULT_LEFT_MARGIN,
          :right_margin => DEFAULT_RIGHT_MARGIN,
          :top_margin => DEFAULT_TOP_MARGIN,
          :bottom_margin => DEFAULT_BOTTOM_MARGIN,
          :gutter => nil,
          :orientation => PORTRAIT,
          :stylesheet_sort => STYLESHEET_SORT_DEFAULT
        }.merge(options)

         @paper           = options.delete(:paper_size)
         @left_margin     = options.delete(:left_margin)
         @right_margin    = options.delete(:right_margin)
         @top_margin      = options.delete(:top_margin)
         @bottom_margin   = options.delete(:bottom_margin)
         @gutter          = options.delete(:gutter)
         @orientation     = options.delete(:orientation)
         @stylesheet_sort = options.delete(:stylesheet_sort)
      end

      # This method overrides the is_document_style? method inherited from the
      # Style class to always return true.
      def is_document_style?
         true
      end

      # This method generates a string containing the prefix associated with a
      # style object.
      #
      # ==== Parameters
      # document::  A reference to the document using the style.
      def prefix(fonts=nil, colours=nil)
         text = StringIO.new

         text << "\\stylesortmethod#{@stylesheet_sort}" unless @stylesheet_sort.nil?
         if orientation == LANDSCAPE
            text << "\\paperw#{@paper.height}"  unless @paper.nil?
            text << "\\paperh#{@paper.width}"   unless @paper.nil?
         else
            text << "\\paperw#{@paper.width}"   unless @paper.nil?
            text << "\\paperh#{@paper.height}"  unless @paper.nil?
         end
         text << "\\margl#{@left_margin}"       unless @left_margin.nil?
         text << "\\margr#{@right_margin}"      unless @right_margin.nil?
         text << "\\margt#{@top_margin}"        unless @top_margin.nil?
         text << "\\margb#{@bottom_margin}"     unless @bottom_margin.nil?
         text << "\\gutter#{@gutter}"           unless @gutter.nil?
         text << '\sectd\lndscpsxn' if @orientation == LANDSCAPE

         text.string
      end

      # This method fetches the width of the available work area space for a
      # DocumentStyle object.
      def body_width
         if orientation == PORTRAIT
            @paper.width - (@left_margin + @right_margin)
         else
            @paper.height - (@left_margin + @right_margin)
         end
      end

      # This method fetches the height of the available work area space for a
      # DocumentStyle object.
      def body_height
         if orientation == PORTRAIT
            @paper.height - (@top_margin + @bottom_margin)
         else
            @paper.width - (@top_margin + @bottom_margin)
         end
      end
   end # End of the DocumentStyle class.
end # End of the RTF module.
