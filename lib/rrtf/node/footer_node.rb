module RRTF
  # This class represents a document footer.
  class FooterNode < CommandNode
     # A definition for a header type.
     UNIVERSAL                                  = :footer

     # A definition for a header type.
     LEFT_PAGE                                  = :footerl

     # A definition for a header type.
     RIGHT_PAGE                                 = :footerr

     # A definition for a header type.
     FIRST_PAGE                                 = :footerf

     # Attribute accessor.
     attr_reader :type

     # Attribute mutator.
     attr_writer :type


     # This is the constructor for the FooterNode class.
     #
     # ==== Parameters
     # document::  A reference to the Document object that will own the new
     #             footer.
     # type::      The style type for the new footer. Defaults to a value of
     #             FooterNode::UNIVERSAL.
     def initialize(document, type=UNIVERSAL)
        super(document, "\\#{type.id2name}", nil, false)
        @type = type
     end

     # This method overloads the footnote method inherited from the CommandNode
     # class to prevent footnotes being added to footers.
     #
     # ==== Parameters
     # text::  Not used.
     #
     # ==== Exceptions
     # RTFError::  Always generated whenever this method is called.
     def footnote(text)
        RTFError.fire("Footnotes are not permitted in page footers.")
     end
  end # End of the FooterNode class.
end
