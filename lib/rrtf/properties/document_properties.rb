require 'stringio'

module RRTF
  # This class represents properties that are to be applied at the
  # document level.
  # @author Wesley Hileman
  # @since 1.0.0
  class DocumentProperties < Properties
    include DocumentFormatting
    include PageFormatting

     # This is a constructor for the DocumentProperties class.
     #
     # @param [Hash] options
     # @option options (see {DocumentFormatting#initialize_document_formatting})
     # @option options (see {PageFormatting#initialize_page_formatting})
     def initialize(options = {})
       initialize_document_formatting(options)
       initialize_page_formatting(options)
     end

     # Converts a document properties object into an RTF sequence.
     #
     # @return [String] the RTF sequence corresponding to the properties object.
     def to_rtf
       rtf = StringIO.new

       rtf << document_formatting_to_rtf
       rtf << page_formatting_to_rtf

       rtf.string
     end
  end # End of the DocumentProperties class
end # module RRTF
