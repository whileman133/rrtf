require 'stringio'

module RRTF
  # This class represents properties that are to be applied to geometry
  # objects.
  # @author Wesley Hileman
  # @since 1.0.0
  class GeometryProperties < Properties

    HORIZONTAL_REFERENCE_DICTIONARY = {
      "MARGIN"          => 0,
      "PAGE"            => 1,
      "COLUMN"          => 2,
      "CHARACTER"       => 3,
      "LEFT_MARGIN"     => 4,
      "RIGHT_MARGIN"    => 5,
      "INSIDE_MARGIN"   => 6,
      "OUTSIDE_MARGIN"  => 7
    }.freeze

    VERTICAL_REFERENCE_DICTIONARY = {
      "MARGIN"          => 0,
      "PAGE"            => 1,
      "PARAGRAPH"       => 2,
      "LINE"            => 3,
      "TOP_MARGIN"      => 4,
      "BOTTOM_MARGIN"   => 5,
      "INSIDE_MARGIN"   => 6,
      "OUTSIDE_MARGIN"  => 7
    }.freeze

    HORIZONTAL_ALIGNMENT_DICTIONARY = {
      "ABSOLUTE"        => 0,
      "LEFT"            => 1,
      "CENTER"          => 2,
      "RIGHT"           => 3,
      "INSIDE"          => 4,
      "OUTSIDE"         => 5
    }.freeze

    VERTICAL_ALIGNMENT_DICTIONARY = {
      "ABSOLUTE"        => 0,
      "TOP"             => 1,
      "CENTER"          => 2,
      "BOTTOM"          => 3,
      "INSIDE"          => 4,
      "OUTSIDE"         => 5
    }.freeze

    WIDTH_REFERENCE_DICTIONARY = {
      "MARGIN"          => 0,
      "PAGE"            => 1,
      "LEFT_MARGIN"     => 2,
      "RIGHT_MARGIN"    => 3,
      "INSIDE_MARGIN"   => 4,
      "OUTSIDE_MARGIN"  => 5
    }.freeze

    HEIGHT_REFERENCE_DICTIONARY = {
      "MARGIN"          => 0,
      "PAGE"            => 1,
      "TOP_MARGIN"      => 2,
      "BOTTOM_MARGIN"   => 3,
      "INSIDE_MARGIN"   => 4,
      "OUTSIDE_MARGIN"  => 5
    }.freeze

    TEXT_WRAP_DICTIONARY = {
      "INLINE"                => {"WRAP" => 1, "SIDE" => nil},
      "AROUND_BOTH"           => {"WRAP" => 2, "SIDE" => 0},
      "AROUND_LEFT"           => {"WRAP" => 2, "SIDE" => 1},
      "AROUND_RIGHT"          => {"WRAP" => 2, "SIDE" => 2},
      "AROUND_LARGEST"        => {"WRAP" => 2, "SIDE" => 3},
      "NONE"                  => {"WRAP" => 3, "SIDE" => nil},
      "TIGHT_AROUND_BOTH"     => {"WRAP" => 4, "SIDE" => 0},
      "TIGHT_AROUND_LEFT"     => {"WRAP" => 4, "SIDE" => 1},
      "TIGHT_AROUND_RIGHT"    => {"WRAP" => 4, "SIDE" => 2},
      "TIGHT_AROUND_LARGEST"  => {"WRAP" => 4, "SIDE" => 3},
    }.freeze

    GEOMERTY_TYPE_DICTIONARY = {
      "CUSTOM"                => 0,
      "RECTANGLE"             => 1,
      "ROUND_RECTANGLE"       => 2,
      "ELLIPSE"               => 3,
      "DIAMOND"               => 4,
      "ISOSCELES_TRIANGLE"    => 5,
      "RIGHT_TRIANGLE"        => 6,
      "PARALLELOGRAM"         => 7,
      "TRAPEZOID"             => 8,
      "HEXAGON"               => 9,
      "OCTAGON"               => 10,
      "PENTAGON"              => 56,
      "LINE"                  => 20,
      "TEXT_BOX"              => 202
    }.freeze

    TEXT_ANCHOR_DICTIONARY = {
      "TOP"                       => 0,
      "MIDDLE"                    => 1,
      "BOTTOM"                    => 2,
      "TOP_CENTERED"              => 3,
      "MIDDLE_CENTERED"           => 4,
      "BOTTOM_CENTERED"           => 5,
      "TOP_BASELINE"              => 6,
      "BOTTOM_BASELINE"           => 7,
      "TOP_CENTERED_BASELINE"     => 8,
      "BOTTOM_CENTERED_BASELINE"  => 9
    }.freeze

    # @note The upper three bits store segment stype, lower 13 bits store the
    #   number of segments of that type to appear in series (always 1 -- except
    #   for control segments -- for the non-compressed encoding used here
    #   where the codes for segments of the same type that appear in series are
    #   repeated).
    PATH_SEGMENT_DICTIONARY = {
      # draw a line from the current point to a specified end point
      # [requires one additional point]
      "LINE_TO"                   => "0001".to_i(16),
      # draw a cubic bezier curve using the current point, two control points,
      # and an end point [requires three additional points]
      "CUBIC_BEZIER_TO"           => "2001".to_i(16),
      # draw a line from the current point to the starting point and close
      # the path [requires no additional points]
      "CLOSE_PATH"                => "6001".to_i(16),
      # start a path (control segment) [requires one point]
      "START_AT"                  => "4000".to_i(16),
      # end a path (control segment) [requires no points]
      "END"                       => "8000".to_i(16)
    }.freeze

     # This is a constructor for the GeometryProperties class.
     #
     # @param [Hash] options
     def initialize(options = {})
       @type                        = GEOMERTY_TYPE_DICTIONARY[options.delete("type")]
       @rotation                    = Utilities.value2geomfrac(options.delete("rotate"))
       @left                        = Utilities.value2twips(options.delete("left"))
       @right                       = Utilities.value2twips(options.delete("right"))
       @top                         = Utilities.value2twips(options.delete("top"))
       @bottom                      = Utilities.value2twips(options.delete("bottom"))
       @z_index                     = options.delete("z_index")
       @horizontal_reference        = HORIZONTAL_REFERENCE_DICTIONARY[options.delete("horizontal_reference")] || HORIZONTAL_REFERENCE_DICTIONARY["MARGIN"]
       @vertical_reference          = VERTICAL_REFERENCE_DICTIONARY[options.delete("vertical_reference")] || VERTICAL_REFERENCE_DICTIONARY["MARGIN"]
       @text_wrap                   = TEXT_WRAP_DICTIONARY[options.delete("text_wrap")]
       @below_text                  = Utilities.value2geombool(options.delete("below_text"))
       @lock_anchor                 = options.delete("lock_anchor")
       @horizontal_alignment        = HORIZONTAL_ALIGNMENT_DICTIONARY[options.delete("horizontal_alignment")] || HORIZONTAL_ALIGNMENT_DICTIONARY["ABSOLUTE"]
       @vertical_alignment          = VERTICAL_ALIGNMENT_DICTIONARY[options.delete("vertical_alignment")] || VERTICAL_ALIGNMENT_DICTIONARY["ABSOLUTE"]
       @allow_overlap               = Utilities.value2geombool(options.delete("allow_overlap"))
       @width_reference             = WIDTH_REFERENCE_DICTIONARY[options.delete("width_reference")] || WIDTH_REFERENCE_DICTIONARY["MARGIN"]
       @height_reference            = HEIGHT_REFERENCE_DICTIONARY[options.delete("height_reference")] || HEIGHT_REFERENCE_DICTIONARY["MARGIN"]
       @width, @width_units         = Utilities.parse_string_with_units(options.delete("width"))
       @height, @height_units       = Utilities.parse_string_with_units(options.delete("height"))
       @width                       = Utilities.value2twips("#{@width}#{@width_units}") unless @width.nil? || @width_units == '%'
       @height                      = Utilities.value2twips("#{@height}#{@height_units}") unless @height.nil? || @height_units == '%'
       @fill_color                  = options.delete("fill_color")
       @has_fill                    = Utilities.value2geombool(options.delete("has_fill") || !@fill_color.nil?)
       @line_color                  = options.delete("line_color")
       @line_width                  = Utilities.value2emu(options.delete("line_width"))
       @has_line                    = Utilities.value2geombool(options.delete("has_line") || !@line_color.nil? || !@line_width.nil?)
       @text_margin                 = options.delete("text_margin")
       @text_anchor                 = TEXT_ANCHOR_DICTIONARY[options.delete("text_anchor")]
       @fit_to_text                 = Utilities.value2geombool(options.delete("fit_to_text"))
       @fit_text_to_shape           = Utilities.value2geombool(options.delete("fit_text_to_shape"))
       @flip_horizontal             = Utilities.value2geombool(options.delete("flip_horizontal"))
       @flip_vertical               = Utilities.value2geombool(options.delete("flip_vertical"))
       @path                        = options.delete("path")
       @path_coordinate_origin      = options.delete("path_coordinate_origin") || [0, 0]
       @path_coordinate_limits      = options.delete("path_coordinate_limits") || [21600, 21600]

       parse_dimensions!
       parse_color! :fill_color, :line_color
       parse_margin! :text_margin
       parse_path!

       unless options.empty?
         RTFError.fire("Unreconized geometry options #{options}.")
       end # unless
     end # initialize()

     # Converts a geometry properties object into an RTF sequence.
     #
     # @return [String] the RTF sequence corresponding to the properties object.
     def to_rtf
       rtf = StringIO.new

       # keyword properties
       rtf << "\\shpleft#{@left}"                         unless @left.nil?
       rtf << "\\shpright#{@right}"                       unless @right.nil?
       rtf << "\\shptop#{@top}"                           unless @top.nil?
       rtf << "\\shpbottom#{@bottom}"                     unless @bottom.nil?
       rtf << "\\shpz#{@z_index}"                         unless @z_index.nil?
       rtf << "\\shpbxpage"                               if @horizontal_reference == HORIZONTAL_REFERENCE_DICTIONARY["PAGE"]
       rtf << "\\shpbxmargin"                             if @horizontal_reference == HORIZONTAL_REFERENCE_DICTIONARY["MARGIN"]
       rtf << "\\shpbxcolumn"                             if @horizontal_reference == HORIZONTAL_REFERENCE_DICTIONARY["COLUMN"]
       rtf << "\\shpbxignore"                             unless @vertical_reference.nil?
       rtf << "\\shpbypage"                               if @vertical_reference == VERTICAL_REFERENCE_DICTIONARY["PAGE"]
       rtf << "\\shpbymargin"                             if @vertical_reference == VERTICAL_REFERENCE_DICTIONARY["MARGIN"]
       rtf << "\\shpbypara"                               if @vertical_reference == VERTICAL_REFERENCE_DICTIONARY["PARAGRAPH"]
       rtf << "\\shpbyignore"                             unless @vertical_reference.nil?
       rtf << "\\shpwr#{@text_wrap["WRAP"]}"              unless @text_wrap.nil? || @text_wrap["WRAP"].nil?
       rtf << "\\shpwrk#{@text_wrap["SIDE"]}"             unless @text_wrap.nil? || @text_wrap["SIDE"].nil?
       rtf << "\\shpfblwtxt#{@below_text}"                unless @below_text.nil?
       rtf << "\\shplockanchor"                           if @lock_anchor

       rtf << "\n"

       # object properties
       rtf << build_property("shapeType", @type)                          unless @type.nil?
       rtf << build_property("rotation", @rotation)                       unless @rotation.nil?
       rtf << build_property("posh", @horizontal_alignment)               unless @horizontal_alignment.nil?
       rtf << build_property("posrelh", @horizontal_reference)            unless @horizontal_reference.nil?
       rtf << build_property("posv", @vertical_alignment)                 unless @vertical_alignment.nil?
       rtf << build_property("posrelv", @vertical_reference)              unless @vertical_reference.nil?
       rtf << build_property("fAllowOverlap", @allow_overlap)             unless @allow_overlap.nil?
       rtf << build_property("pctHoriz", @width)                          unless @width.nil? || @width_units != '%'
       rtf << build_property("pctVert", @height)                          unless @height.nil? || @height_units != '%'
       rtf << build_property("sizerelh", @width_reference)                unless @width_reference.nil?
       rtf << build_property("sizerelv", @height_reference)               unless @height_reference.nil?
       rtf << build_property("fFilled", @has_fill)                        unless @has_fill.nil?
       rtf << build_property("fillColor", @fill_color)                    unless @fill_color.nil?
       rtf << build_property("fLine", @has_line)                          unless @has_fill.nil?
       rtf << build_property("lineColor", @line_color)                    unless @line_color.nil?
       rtf << build_property("lineWidth", @line_width)                    unless @line_width.nil?
       rtf << build_property("dxTextLeft", @text_margin_left)             unless @text_margin_left.nil?
       rtf << build_property("dxTextRight", @text_margin_right)           unless @text_margin_right.nil?
       rtf << build_property("dyTextTop", @text_margin_top)               unless @text_margin_top.nil?
       rtf << build_property("dyTextBottom", @text_margin_bottom)         unless @text_margin_bottom.nil?
       rtf << build_property("anchorText", @text_anchor)                  unless @text_anchor.nil?
       rtf << build_property("fBehindDocument", @below_text)              unless @below_text.nil?
       rtf << build_property("fFitShapeToText", @fit_to_text)             unless @fit_to_text.nil?
       rtf << build_property("fFitTextToShape", @fit_text_to_shape)       unless @fit_text_to_shape.nil?
       rtf << build_property("fFlipH", @flip_horizontal)                  unless @flip_horizontal.nil?
       rtf << build_property("fFlipV", @flip_vertical)                    unless @flip_vertical.nil?
       rtf << build_property("geoLeft", @path_coordinate_origin[0])       unless @path.nil? || @path_coordinate_origin.nil?
       rtf << build_property("geoTop", @path_coordinate_origin[1])        unless @path.nil? || @path_coordinate_origin.nil?
       rtf << build_property("geoRight", @path_coordinate_limits[0])      unless @path.nil? || @path_coordinate_limits.nil?
       rtf << build_property("geoBottom", @path_coordinate_limits[1])     unless @path.nil? || @path_coordinate_limits.nil?
       rtf << build_property("pVerticies", @path_verticies)               unless @path.nil? || @path_verticies.nil?
       rtf << build_property("pSegmentInfo", @path_segment_info)          unless @path.nil? || @path_segment_info.nil?
       rtf << build_property("pConnectionSites", @path_connection_sites)  unless @path.nil? || @path_connection_sites.nil?
       rtf << build_property("fLineOK", 1)
       rtf << build_property("fFillOK", 1)
       rtf << build_property("f3DOK", 1)

       rtf.string
     end

     private

     def build_property(name, value)
       "{\\sp{\\sn #{name}}{\\sv #{value}}}\n"
     end

     def build_array(array, bytes_per_element)
       "#{bytes_per_element};#{array.length};#{array.join(';')}"
     end

     def array2emu(array)
       array.collect{ |el| Utilities.value2emu(el) }
     end

     def parse_dimensions!
       unless @width.nil?
         if @width_units == '%'
           @percent_width = @width
         else
           case [@left.nil?, @right.nil?]
           when [true, true]
             @left = 0
             @right = @width
           when [true, false]
             @left = @right - @width
           when [false, true]
             @right = @left + @width
           end # case
         end # if
       end # unless

       unless @height.nil?
         if @height_units == '%'
           @percent_height = @height
         else
           case [@top.nil?, @bottom.nil?]
           when [true, true]
             @top = 0
             @bottom = @height
           when [true, false]
             @top = @bottom - @height
           when [false, true]
             @bottom = @top + @height
           end # case
         end # if
       end # unless
     end # parse_dimensions()

     def parse_color!(*color_attrs)
       color_attrs.each do |color_attr|
         color = instance_variable_get(:"@#{color_attr}")

         unless color.nil?
           case color
           when String
             color = Colour.from_string(color).to_decimal("reverse_bytes" => true)
           when Colour
             color = color.to_decimal
           else
             RTFError.fire("Unsupported color format #{color}.")
           end # case
         end # unless

         instance_variable_set(:"@#{color_attr}", color)
       end # each
     end # parse_color()

     def parse_margin!(*margin_attrs)
       margin_attrs.each do |margin_attr|
         margin = instance_variable_get("@#{margin_attr}")
         next if margin.nil?

         margin = Page::Margin.new(margin)
         left = Utilities.value2emu("#{margin.left}twip")
         right = Utilities.value2emu("#{margin.right}twip")
         top = Utilities.value2emu("#{margin.top}twip")
         bottom = Utilities.value2emu("#{margin.bottom}twip")

         instance_variable_set("@#{margin_attr}", margin)
         instance_variable_set("@#{margin_attr}_left", left)
         instance_variable_set("@#{margin_attr}_right", right)
         instance_variable_set("@#{margin_attr}_top", top)
         instance_variable_set("@#{margin_attr}_bottom", bottom)
       end
     end # parse_margin()

     def parse_path!
       return if @path.nil?

       verticies = []
       connection_sites = []
       seg_info = []

       unless @path.is_a?(Array) && @path.collect{ |tup| tup.is_a?(Array) && (1..5).include?(tup.length) }.all?
         RTFError.fire("Path segments must be an array of arrays with length 1 through 5.")
       end # unless

       sx = (@path_coordinate_limits[0] - @path_coordinate_origin[0]).to_f/(Utilities.value2emu("#{@width}twip")).to_f
       sy = (@path_coordinate_limits[1] - @path_coordinate_origin[1]).to_f/(Utilities.value2emu("#{@height}twip")).to_f

       @path.each do |seg|
         # first item in segment array gives the segment type
         type = seg[0]

         if PATH_SEGMENT_DICTIONARY[type].nil?
           RTFError.fire("Invalid segment type '#{type}'.")
         end # case

         if seg.length > 1
           # remaining items give the points associated with the segment
           # (last element is the end point; bezier curves also have a control
           # point before last point; the starting point is given by the end
           # point of the last segment)
           points = seg[1..(seg.length - 1)].collect{ |p| array2emu(p) }.collect{ |p| [(p[0]*sx).round, (p[1]*sy).round] }
           verticies += points
           # the last point is the endpoint for the segment that forms a
           # "connection site" with the next segment
           connection_sites << points.last
         end # if

         # add appropriate code to the segment information array indicating the
         # type of segment to create
         seg_info << PATH_SEGMENT_DICTIONARY[type]
       end # each

       @path_verticies        = build_array(verticies.collect{ |v| "(#{v[0]},#{v[1]})" }, 8)
       @path_connection_sites = build_array(connection_sites.collect{ |s| "(#{s[0]},#{s[1]})" }, 8)
       @path_segment_info     = build_array(seg_info, 2)
     end # parse_path()
  end # End of the DocumentProperties class
end # module RRTF
