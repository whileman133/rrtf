module RRTF
  # This class represents styling attributes that are to be applied at the
  # document level.
  class DocumentStyle < Style
     # Definition for a document orientation setting.
     PORTRAIT                                   = :portrait

     # Definition for a document orientation setting.
     LANDSCAPE                                  = :landscape

     # Definition for a default margin setting.
     DEFAULT_LEFT_MARGIN                        = 1800

     # Definition for a default margin setting.
     DEFAULT_RIGHT_MARGIN                       = 1800

     # Definition for a default margin setting.
     DEFAULT_TOP_MARGIN                         = 1440

     # Definition for a default margin setting.
     DEFAULT_BOTTOM_MARGIN                      = 1440

     # stylesheet sorting codes
     STYLESHEET_SORT_NAME       = 0 # stylesheet styles sorted by name
     STYLESHEET_SORT_DEFAULT    = 1 # stylesheet styles sorted by system default
     STYLESHEET_SORT_FONT       = 2 # stylesheet styles sorted by font
     STYLESHEET_SORT_BASEDON    = 3 # stylesheet styles sorted by based-on fonts
     STYLESHEET_SORT_TYPE       = 4 # stylesheet styles sorted by type

     # Attribute accessor.
     attr_reader :paper, :left_margin, :right_margin, :top_margin,
                 :bottom_margin, :gutter, :orientation, :stylesheet_sort

     # Attribute mutator.
     attr_writer :paper, :left_margin, :right_margin, :top_margin,
                 :bottom_margin, :gutter, :orientation, :stylesheet_sort

     # This is a constructor for the DocumentStyle class. This creates a
     # document style with a default paper setting of LETTER and portrait
     # orientation (all other attributes are nil).
     def initialize(options = {})
       # load default options
       options = {
         "paper_size" => Paper::LETTER,
         "left_margin" => DEFAULT_LEFT_MARGIN,
         "right_margin" => DEFAULT_RIGHT_MARGIN,
         "top_margin" => DEFAULT_TOP_MARGIN,
         "bottom_margin" => DEFAULT_BOTTOM_MARGIN,
         "gutter" => nil,
         "orientation" => PORTRAIT,
         "stylesheet_sort" => STYLESHEET_SORT_DEFAULT
       }.merge(options)

        @paper           = options.delete("paper_size")
        @left_margin     = options.delete("left_margin")
        @right_margin    = options.delete("right_margin")
        @top_margin      = options.delete("top_margin")
        @bottom_margin   = options.delete("bottom_margin")
        @gutter          = options.delete("gutter")
        @orientation     = options.delete("orientation")
        @stylesheet_sort = options.delete("stylesheet_sort")
     end

     # This method overrides the is_document_style? method inherited from the
     # Style class to always return true.
     def is_document_style?
        true
     end

     # This method generates a string containing the prefix associated with a
     # style object.
     #
     # ==== Parameters
     # document::  A reference to the document using the style.
     def prefix(fonts=nil, colours=nil)
        text = StringIO.new

        text << "\\stylesortmethod#{@stylesheet_sort}" unless @stylesheet_sort.nil?
        if orientation == LANDSCAPE
           text << "\\paperw#{@paper.height}"  unless @paper.nil?
           text << "\\paperh#{@paper.width}"   unless @paper.nil?
        else
           text << "\\paperw#{@paper.width}"   unless @paper.nil?
           text << "\\paperh#{@paper.height}"  unless @paper.nil?
        end
        text << "\\margl#{@left_margin}"       unless @left_margin.nil?
        text << "\\margr#{@right_margin}"      unless @right_margin.nil?
        text << "\\margt#{@top_margin}"        unless @top_margin.nil?
        text << "\\margb#{@bottom_margin}"     unless @bottom_margin.nil?
        text << "\\gutter#{@gutter}"           unless @gutter.nil?
        text << '\sectd\lndscpsxn' if @orientation == LANDSCAPE

        text.string
     end

     # This method fetches the width of the available work area space for a
     # DocumentStyle object.
     def body_width
        if orientation == PORTRAIT
           @paper.width - (@left_margin + @right_margin)
        else
           @paper.height - (@left_margin + @right_margin)
        end
     end

     # This method fetches the height of the available work area space for a
     # DocumentStyle object.
     def body_height
        if orientation == PORTRAIT
           @paper.height - (@top_margin + @bottom_margin)
        else
           @paper.width - (@top_margin + @bottom_margin)
        end
     end
  end # End of the DocumentStyle class.
end # module RRTF
