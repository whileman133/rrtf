module RRTF
  # This class represents a cell within an RTF table. The TableCellNode is a
  # specialised command node that is forbidden from creating tables or having
  # its parent changed.
  class TableCellNode < CommandNode
     # A definition for the default width for the cell.
     DEFAULT_WIDTH                              = 300
     # Top border
     TOP = 0
     # Right border
     RIGHT = 1
     # Bottom border
     BOTTOM = 2
     # Left border
     LEFT = 3
     # Width of cell
     attr_accessor :width
     # Attribute accessor.
     attr_reader :shading_colour, :style

     # This is the constructor for the TableCellNode class.
     #
     # ==== Parameters
     # row::     The row that the cell belongs to.
     # width::   The width to be assigned to the cell. This defaults to
     #           TableCellNode::DEFAULT_WIDTH.
     # style::   The style that is applied to the cell. This must be a
     #           ParagraphStyle class. Defaults to nil.
     # top::     The border width for the cells top border. Defaults to nil.
     # right::   The border width for the cells right hand border. Defaults to
     #           nil.
     # bottom::  The border width for the cells bottom border. Defaults to nil.
     # left::    The border width for the cells left hand border. Defaults to
     #           nil.
     #
     # ==== Exceptions
     # RTFError::  Generated whenever an invalid style setting is specified.
     def initialize(row, width=DEFAULT_WIDTH, style=nil, top=nil, right=nil,
                    bottom=nil, left=nil)
        super(row, nil)
        if !style.nil? and !style.is_paragraph_style?
           RTFError.fire("Non-paragraph style specified for TableCellNode "\
                         "constructor.")
        end

        @width          = (width != nil && width > 0) ? width : DEFAULT_WIDTH
        @borders        = [(top != nil && top > 0) ? top : nil,
                           (right != nil && right > 0) ? right : nil,
                           (bottom != nil && bottom > 0) ? bottom : nil,
                           (left != nil && left > 0) ? left : nil]
        @shading_colour = nil
        @style          = style
     end

     # Attribute mutator.
     #
     # ==== Parameters
     # style::  A reference to the style object to be applied to the cell.
     #          Must be an instance of the ParagraphStyle class. Set to nil
     #          to clear style settings.
     #
     # ==== Exceptions
     # RTFError::  Generated whenever an invalid style setting is specified.
     def style=(style)
        if !style.nil? and !style.is_paragraph_style?
           RTFError.fire("Non-paragraph style specified for TableCellNode "\
                         "constructor.")
        end
        @style = style
     end

     # This method assigns a width, in twips, for the borders on all sides of
     # the cell. Negative widths will be ignored and a width of zero will
     # switch the border off.
     #
     # ==== Parameters
     # width::  The setting for the width of the border.
     def border_width=(width)
        size = width.nil? ? 0 : width
        if size > 0
           @borders[TOP] = @borders[RIGHT] = @borders[BOTTOM] = @borders[LEFT] = size.to_i
        else
           @borders = [nil, nil, nil, nil]
        end
     end

     # This method assigns a border width to the top side of a table cell.
     # Negative values are ignored and a value of 0 switches the border off.
     #
     # ==== Parameters
     # width::  The new border width setting.
     def top_border_width=(width)
        size = width.nil? ? 0 : width
        if size > 0
           @borders[TOP] = size.to_i
        else
           @borders[TOP] = nil
        end
     end

     # This method assigns a border width to the right side of a table cell.
     # Negative values are ignored and a value of 0 switches the border off.
     #
     # ==== Parameters
     # width::  The new border width setting.
     def right_border_width=(width)
        size = width.nil? ? 0 : width
        if size > 0
           @borders[RIGHT] = size.to_i
        else
           @borders[RIGHT] = nil
        end
     end

     # This method assigns a border width to the bottom side of a table cell.
     # Negative values are ignored and a value of 0 switches the border off.
     #
     # ==== Parameters
     # width::  The new border width setting.
     def bottom_border_width=(width)
        size = width.nil? ? 0 : width
        if size > 0
           @borders[BOTTOM] = size.to_i
        else
           @borders[BOTTOM] = nil
        end
     end

     # This method assigns a border width to the left side of a table cell.
     # Negative values are ignored and a value of 0 switches the border off.
     #
     # ==== Parameters
     # width::  The new border width setting.
     def left_border_width=(width)
        size = width.nil? ? 0 : width
        if size > 0
           @borders[LEFT] = size.to_i
        else
           @borders[LEFT] = nil
        end
     end

     # This method alters the shading colour associated with a TableCellNode
     # object.
     #
     # ==== Parameters
     # colour::  A reference to the Colour object to use in shading the cell.
     #           Assign nil to clear cell shading.
     def shading_colour=(colour)
        root.colours << colour
        @shading_colour = colour
     end

     # This method retrieves an array with the cell border width settings.
     # The values are inserted in top, right, bottom, left order.
     def border_widths
        widths = []
        @borders.each {|entry| widths.push(entry.nil? ? 0 : entry)}
        widths
     end

     # This method fetches the width for top border of a cell.
     def top_border_width
        @borders[TOP].nil? ? 0 : @borders[TOP]
     end

     # This method fetches the width for right border of a cell.
     def right_border_width
        @borders[RIGHT].nil? ? 0 : @borders[RIGHT]
     end

     # This method fetches the width for bottom border of a cell.
     def bottom_border_width
        @borders[BOTTOM].nil? ? 0 : @borders[BOTTOM]
     end

     # This method fetches the width for left border of a cell.
     def left_border_width
        @borders[LEFT].nil? ? 0 : @borders[LEFT]
     end

     # This method overloads the paragraph method inherited from the
     # ComamndNode class to forbid the creation of paragraphs.
     #
     # ==== Parameters
     # style::  The paragraph style, ignored
     def paragraph(style=nil)
        RTFError.fire("TableCellNode#paragraph() called. Table cells cannot "\
                      "contain paragraphs.")
     end

     # This method overloads the parent= method inherited from the Node class
     # to forbid the alteration of the cells parent.
     #
     # ==== Parameters
     # parent::  A reference to the new node parent.
     def parent=(parent)
        RTFError.fire("Table cell nodes cannot have their parent changed.")
     end

     # This method overrides the table method inherited from CommandNode to
     # forbid its use in table cells.
     #
     # ==== Parameters
     # rows::     The number of rows for the table.
     # columns::  The number of columns for the table.
     # *widths::  One or more integers representing the widths for the table
     #            columns.
     def table(rows, columns, *widths)
        RTFError.fire("TableCellNode#table() called. Nested tables not allowed.")
     end

     # This method generates the RTF document text for a TableCellNode object.
     def to_rtf
        text      = StringIO.new
        separator = split? ? "\n" : " "
        line      = (separator == " ")

        text << "\\pard\\intbl"
        text << @style.prefix(root) if @style != nil
        text << separator
        self.each do |entry|
           text << "\n" if line
           line = true
           text << entry.to_rtf
        end
        text << (split? ? "\n" : " ")
        text << "\\cell"

        text.string
     end
  end # End of the TableCellNode class.
end
