module RRTF
  # This class represents a document header.
  class HeaderNode < CommandNode
     # A definition for a header type.
     UNIVERSAL                                  = :header

     # A definition for a header type.
     LEFT_PAGE                                  = :headerl

     # A definition for a header type.
     RIGHT_PAGE                                 = :headerr

     # A definition for a header type.
     FIRST_PAGE                                 = :headerf

     # Attribute accessor.
     attr_reader :type

     # Attribute mutator.
     attr_writer :type


     # This is the constructor for the HeaderNode class.
     #
     # ==== Parameters
     # document::  A reference to the Document object that will own the new
     #             header.
     # type::      The style type for the new header. Defaults to a value of
     #             HeaderNode::UNIVERSAL.
     def initialize(document, type=UNIVERSAL)
        super(document, "\\#{type.id2name}", nil, false)
        @type = type
     end

     # This method overloads the footnote method inherited from the CommandNode
     # class to prevent footnotes being added to headers.
     #
     # ==== Parameters
     # text::  Not used.
     #
     # ==== Exceptions
     # RTFError::  Always generated whenever this method is called.
     def footnote(text)
        RTFError.fire("Footnotes are not permitted in page headers.")
     end
  end # End of the HeaderNode class.
end
