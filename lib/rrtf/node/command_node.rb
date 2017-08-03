module RRTF
  # This class represents a RTF command element within a document. This class
  # is concrete enough to be used on its own but will also be used as the
  # base class for some specific command node types.
  class CommandNode < ContainerNode
     # String containing the prefix text for the command
     attr_accessor :prefix
     # String containing the suffix text for the command
     attr_accessor :suffix
     # A boolean to indicate whether the prefix and suffix should
     # be written to separate lines whether the node is converted
     # to RTF. Defaults to true
     attr_accessor :split
     # A boolean to indicate whether the prefix and suffix should
     # be wrapped in curly braces. Defaults to true.
     attr_accessor :wrap

     # This is the constructor for the CommandNode class.
     #
     # ==== Parameters
     # parent::  A reference to the node that owns the new node.
     # prefix::  A String containing the prefix text for the command.
     # suffix::  A String containing the suffix text for the command. Defaults
     #           to nil.
     # split::   A boolean to indicate whether the prefix and suffix should
     #           be written to separate lines whether the node is converted
     #           to RTF. Defaults to true.
     # wrap::    A boolean to indicate whether the prefix and suffix should
     #           be wrapped in curly braces. Defaults to true.
     def initialize(parent, prefix, suffix=nil, split=true, wrap=true)
        super(parent)
        @prefix = prefix
        @suffix = suffix
        @split  = split
        @wrap   = wrap
     end

     # This method adds text to a command node. If the last child node of the
     # target node is a TextNode then the text is appended to that. Otherwise
     # a new TextNode is created and append to the node.
     #
     # ==== Parameters
     # text::  The String of text to be written to the node.
     def <<(text)
        if !last.nil? and last.respond_to?(:text=)
           last.append(text)
        else
           self.store(TextNode.new(self, text))
        end
     end

     # This method generates the RTF text for a CommandNode object.
     def to_rtf
        text = StringIO.new

        text << '{'       if wrap?
        text << @prefix   if @prefix

        self.each do |entry|
           text << "\n" if split?
           text << entry.to_rtf
        end

        text << "\n"    if split?
        text << @suffix if @suffix
        text << '}'     if wrap?

        text.string
     end

     def section(style = nil)
       # parse style
       case style
       when Hash
         style = SectionStyle.new(style)
       when SectionStyle
         # use without modification
       when nil
         # allow nil style
       else
         RTFError.fire("Invalid section style '#{style}'.")
       end # case

       node = SectionNode.new(self, style)
       yield node if block_given?
       self.store(node)
     end

     # This method provides a short cut means of creating a paragraph command
     # node. The method accepts a block that will be passed a single parameter
     # which will be a reference to the paragraph node created. After the
     # block is complete the paragraph node is appended to the end of the child
     # nodes on the object that the method is called against.
     #
     # @param [Hash, ParagraphStyle] style a reference to a ParagraphStyle
     #   object that contains the style settings to be applied OR a hash of
     #   paragraph formatting settings (aka an anonymous style).
     # @raise [RTFError] whenever a non-paragraph style is specified.
     #
     # @example Applying an anonymous style.
     #   rtf = Document.new
     #   rtf.paragraph("bold" => true, "font" => "SWISS:Arial") do |p|
     #     p << "Paragraph formatted with an anonymous style."
     #   end
     def paragraph(style = nil)
       # parse style
       case style
       when Hash
         style = ParagraphStyle.new(style)
       when ParagraphStyle
         # use without modification
       when nil
         # allow nil style
       else
         RTFError.fire("Invalid paragraph style '#{style}'.")
       end # case

       # Store fonts and colours used in style in font and colour tables.
       style.push_colours(root.colours) unless style.nil?
       style.push_fonts(root.fonts) unless style.nil?

       node = ParagraphNode.new(self, style)
       yield node if block_given?
       self.store(node)
     end

     # This method provides a short cut means of creating a new ordered or
     # unordered list. The method requires a block that will be passed a
     # single parameter that'll be a reference to the first level of the
     # list. See the +ListLevelNode+ doc for more information.
     #
     # Example usage:
     #
     #   rtf.list do |level1|
     #     level1.item do |li|
     #       li << 'some text'
     #       li.apply(some_style) {|x| x << 'some styled text'}
     #     end
     #
     #     level1.list(:decimal) do |level2|
     #       level2.item {|li| li << 'some other text in a decimal list'}
     #       level2.item {|li| li << 'and here we go'}
     #     end
     #   end
     #
     def list(kind=:bullets)
       node = ListNode.new(self)
       yield node.list(kind)
       self.store(node)
     end

     def link(url, text=nil)
       node = LinkNode.new(self, url)
       node << text if text
       yield node   if block_given?
       self.store(node)
     end

     # This method provides a short cut means of creating a line break command
     # node. This command node does not take a block and may possess no other
     # content.
     def line_break
        self.store(CommandNode.new(self, '\line', nil, false))
        nil
     end

     # This method provides a short cut means of creating a column break command
     # node. This command node does not take a block and may possess no other
     # content.
     def column_break
        self.store(CommandNode.new(self, '\column', nil, false))
        nil
     end

     # This method provides a short cut means of creating a tab command
     # node. This command node does not take a block and may possess no other
     # content.
     def tab
        self.store(CommandNode.new(self, '\tab', nil, false))
        nil
     end

     # This method inserts a footnote at the current position in a node.
     #
     # ==== Parameters
     # text::  A string containing the text for the footnote.
     def footnote(text)
        if !text.nil? and text != ''
           mark = CommandNode.new(self, '\fs16\up6\chftn', nil, false)
           note = CommandNode.new(self, '\footnote {\fs16\up6\chftn}', nil, false)
           note.paragraph << text
           self.store(mark)
           self.store(note)
        end
     end

     # This method inserts a new image at the current position in a node.
     # @see ImageNode
     #
     # @param [String, File] source either a string containing the path and name
     #   of a file or a File object for the image file to be inserted.
     # @param [Hash<String, Object>] options a hash of options.
     # @option (see {ImageNode#initialize})
     # @raise [RTFError] whenever an invalid or inaccessible file is
     #   specified or the image file type is not supported.
     def image(source, options = {})
        self.store(ImageNode.new(self, source, root.get_id, options))
     end

     # This method creates a new table node and returns it. The method accepts
     # a block that will be passed the table as a parameter. The node is added
     # to the node the method is called upon after the block is complete.
     #
     # ==== Parameters
     # rows::     The number of rows that the table contains.
     # columns::  The number of columns that the table contains.
     # *widths::  One or more integers representing the widths for the table
     #            columns.
     def table(rows, columns, *widths)
        node = TableNode.new(self, rows, columns, *widths)
        yield node if block_given?
        store(node)
        node
     end

     def geometry(properties = nil)
       node = GeometryNode.new(self, properties)
       yield node if block_given?
       store(node)
       node
     end

     # This method provides a short cut means for applying multiple styles via
     # single command node. The method accepts a block that will be passed a
     # reference to the node created. Once the block is complete the new node
     # will be append as the last child of the CommandNode the method is called
     # on.
     #
     # @param [Hash, CharacterStyle] style a reference to a CharacterStyle
     #   object that contains the style settings to be applied OR a hash of
     #   character formatting settings (aka an anonymous style).
     # @raise [RTFError] whenever a non-character style is specified.
     #
     # @example Applying an anonymous style.
     #   rtf = Document.new
     #   rtf.paragraph do |p|
     #     p.apply("bold" => true, "font" => "SWISS:Arial") do |text|
     #       text << "Text formatted with an anonymous style."
     #     end
     #   end
     def apply(style)
        # Check the input style.
        case style
        when Hash
          style = CharacterStyle.new(style)
        when CharacterStyle
          # use without modification
        else
          RTFError.fire("Invalid character style style '#{style}'.")
        end # case

        # Store fonts and colours used in style in font and colour tables.
        style.push_colours(root.colours)
        style.push_fonts(root.fonts)

        # Generate the command node.
        node = CommandNode.new(self, style.prefix(root))
        yield node if block_given?
        self.store(node)
     end

     alias :write  :<<
     alias :split? :split
     alias :wrap?  :wrap
  end # End of the CommandNode class.
end
