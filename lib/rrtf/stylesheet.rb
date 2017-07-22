#!/usr/bin/env ruby

require 'stringio'

module RRTF

  # Class that represents a stylesheet in an RTF document
  class Stylesheet
    # @styles::: An array of styles associated with the stylesheet

    # The document to which the stylesheet belongs
    attr_accessor :document

    # Converts an array of hashmaps representing styles into a stylesheet
    def self.from_hashmap_array(hashmap_array, document = nil)
      styles = []

      hashmap_array.each do |encoded_style|
        type = encoded_style.delete("type")

        case type
        when "paragraph"
          styles << ParagraphStyle.from_hashmap(encoded_style)
        when "character"
          styles << CharacterStyle.from_hashmap(encoded_style)
        else
          RTFError.fire("Unreconized style type '#{type.to_s}'.")
        end # case
      end # each

      self.new(styles, document)
    end # self.from_hashmap_array()

    def initialize(styles = [], document = nil)
      @document = document
      @styles = []
      styles.each {|style| add(style)}
    end

    # Adds a style to the stylesheet
    def add(style, options = {})
      if style.kind_of?(Style)
        return true unless @styles.index(style).nil?

        # Auto-assign handle to style if nil
        if style.handle.nil?
          # default style takes on the '0' handle
          style.handle = options[:default] ? 0 : @styles.length + 1
        end # if
        # Auto-assign priority if nil
        if style.priority.nil?
          style.priority = @styles.length
        end # if

        # Add style fonts and colours to respective tables
        style.push_colours(document.colours)
        style.push_fonts(document.fonts)

        @styles.push(style)
        true
      else
        false
      end # if
    end # add()

    # Converts the stylesheet to its RTF representation
    def to_rtf(fonts, colours)
      rtf = StringIO.new

      rtf << "{\\stylesheet"
      @styles.each {|style| rtf << "\n#{style.to_rtf(fonts, colours)}"}
      rtf << "\n}"

      rtf.string
    end # to_rtf()

    # Returns a hashmap of styles associated with the stylesheet
    def styles
      s = {}
      @styles.each {|style| s[style.id] = style}
      s
    end
  end # class Stlesheet

end # module RRTF
