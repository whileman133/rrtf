require 'stringio'

module RRTF
  # This class represents a character style for an RTF document.
  class CharacterStyle < Style
    include CharacterFormatting

     # This is the constructor for the CharacterStyle class.
     #
     # @param [Hash] options the character style options.
     # @option options (see Style#initialize)
     # @option options (see CharacterFormatting#initialize_character_formatting)
     def initialize(options = {})
        super(options)
        initialize_character_formatting(options)
     end

     # Converts the stylesheet character style into its RTF representation
     # (for stylesheet)
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
       rtf << "{\\*\\cs#{handle}#{suffix}"
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

     # This method generates a string containing the prefix associated with the
     # style object.
     def prefix(document)
       text = StringIO.new

       text << "\\cs#{handle} " unless handle.nil?
       text << rtf_formatting(document)

       text.string
     end

     def rtf_formatting(document)
       character_formatting_to_rtf(document)
     end
  end # End of the CharacterStyle class.
end # module RRTF
