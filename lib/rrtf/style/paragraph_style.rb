require 'stringio'

module RRTF
  # This class represents a styling for a paragraph within an RTF document.
  # @note paragraphs can be styled with character commands in addition to
  #   paragraph commands, thus this class includes both paragraph & character
  #   formatting modules.
  class ParagraphStyle < Style
    include ParagraphFormatting
    include CharacterFormatting

    # This is the constructor for the CharacterStyle class.
    #
    # @param [Hash] options the character style options.
    # @option options (see Style#initialize)
    # @option options (see CharacterFormatting#initialize_character_formatting)
    # @option options (see ParagraphFormatting#initialize_paragraph_formatting)
     def initialize(options = {})
        super(options)
        initialize_paragraph_formatting(options)
        initialize_character_formatting(options)
     end

     # Converts the stylesheet paragraph style into its RTF representation
     #
     # ==== Parameters
     # fonts::    A reference to a FontTable containing any fonts used by the
     #            style (may be nil if no fonts used).
     # colours::  A reference to a ColourTable containing any colours used by
     #            the style (may be nil if no colours used).
     def to_rtf(document, options = {})
       # load default options
       options = {
         "uglify" => false,
         "base_indent" => 0
       }.merge(options)
       # build formatting helpers
       base_prefix = options["uglify"] ? '' : ' '*options["base_indent"]
       name_prefix = options["uglify"] ? ' ' : ''
       suffix = options["uglify"] ? '' : ' '

       rtf = StringIO.new

       rtf << base_prefix
       rtf << "{\\s#{handle}#{suffix}"
       rtf << "#{rtf_formatting(document)}#{suffix}"
       rtf << "\\additive#{suffix}" if @additive
       rtf << "\\sbasedon#{@based_on_style_handle}#{suffix}" unless @based_on_style_handle.nil?
       rtf << "\\sautoupd#{suffix}" if @auto_update
       rtf << "\\snext#{@next_style_handle}#{suffix}" unless @next_style_handle.nil?
       rtf << "\\sqformat#{suffix}" if @primary
       rtf << "\\spriority#{@priority}#{suffix}" unless @priority.nil?
       rtf << "\\shidden#{suffix}" if @hidden
       rtf << "#{name_prefix}#{name};}"

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
     def prefix(document)
       text = StringIO.new

       text << "\\s#{handle} " unless handle.nil?
       text << rtf_formatting(document)

       text.string
     end

     def rtf_formatting(document)
       rtf = StringIO.new

       pf = paragraph_formatting_to_rtf(document)
       cf = character_formatting_to_rtf(document)

       rtf << pf unless pf.nil?
       rtf << cf unless cf.nil?

       rtf.string
     end
  end # End of the ParagraphStyle class.
end # module RRTF
