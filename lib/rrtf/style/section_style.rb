require 'stringio'

module RRTF
  # This class represents a section style for an RTF document.
  class SectionStyle < Style
    include SectionFormatting
    include PageFormatting

     # This is the constructor for the SectionStyle class.
     #
     # @param [Hash] options the section style options.
     # @option options (see Style#initialize)
     # @option options (see SectionFormatting#initialize_section_formatting)
     # @option options (see PageFormatting#initialize_page_formatting)
     def initialize(options = {})
        super(options)
        initialize_section_formatting(options)
        initialize_page_formatting(options)
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
       rtf << "{\\*\\ds#{handle}#{suffix}"
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

       text << "\\ds#{handle} " unless handle.nil?
       text << rtf_formatting

       text.string
     end

     def rtf_formatting
       "#{section_formatting_to_rtf} #{page_formatting_to_rtf}"
     end
  end # End of the CharacterStyle class.
end # module RRTF
