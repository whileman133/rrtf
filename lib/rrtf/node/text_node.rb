require 'stringio'

module RRTF
  # This class represents a specialisation of the Node class to refer to a Node
  # that simply contains text.
  class TextNode < Node
    # Actual text
     attr_accessor :text

     # This is the constructor for the TextNode class.
     #
     # ==== Parameters
     # parent::  A reference to the Node that owns the TextNode. Must not be
     #           nil.
     # text::    A String containing the node text. Defaults to nil.
     #
     # ==== Exceptions
     # RTFError::  Generated whenever an nil parent object is specified to
     #             the method.
     def initialize(parent, text=nil)
        super(parent)
        if parent.nil?
           RTFError.fire("Nil parent specified for text node.")
        end
        @parent = parent
        @text   = text
     end

     # This method concatenates a String on to the end of the existing text
     # within a TextNode object.
     #
     # ==== Parameters
     # text::  The String to be added to the end of the text node.
     def append(text)
       @text = (@text.nil?) ? text.to_s : @text + text.to_s
     end

     # This method inserts a String into the existing text within a TextNode
     # object. If the TextNode contains no text then it is simply set to the
     # text passed in. If the offset specified is past the end of the nodes
     # text then it is simply appended to the end.
     #
     # ==== Parameters
     # text::    A String containing the text to be added.
     # offset::  The numbers of characters from the first character to insert
     #           the new text at.
     def insert(text, offset)
        if !@text.nil?
           @text = @text[0, offset] + text.to_s + @text[offset, @text.length]
        else
           @text = text.to_s
        end
     end

     # This method generates the RTF equivalent for a TextNode object. This
     # method escapes any special sequences that appear in the text.
     def to_rtf
       rtf=(@text.nil? ? '' : @text.gsub("{", "\\{").gsub("}", "\\}").gsub("\\", "\\\\"))
       # This is from lfarcy / rtf-extensions
       # I don't see the point of coding different 128<n<256 range

       #f1=lambda { |n| n < 128 ? n.chr : n < 256 ? "\\'#{n.to_s(16)}" : "\\u#{n}\\'3f" }
       # Encode as Unicode.

       f=lambda { |n| n < 128 ? n.chr : "\\u#{n}\\'3f" }
       # Ruby 1.9 is safe, cause detect original encoding
       # and convert text to utf-16 first
       if RUBY_VERSION>"1.9.0"
         return rtf.encode("UTF-16LE", :undef=>:replace).each_codepoint.map(&f).join('')
       else
         # You SHOULD use UTF-8 as input, ok?
         return rtf.unpack('U*').map(&f).join('')
       end
     end
  end # End of the TextNode class.
end
