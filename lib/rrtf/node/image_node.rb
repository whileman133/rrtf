require 'fastimage'
require 'open-uri'

module RRTF
  # This class represents an image within a RTF document. Currently only the
  # PNG, JPEG and Windows Bitmap formats are supported. Efforts are made to
  # identify the file type but these are not guaranteed to work.
  # @author Peter Wood
  # @author Wesley Hileman
  # @since legacy
  class ImageNode < Node
    # Supported image types.
    TYPE_DICTIONARY = {
      :png => 'pngblip',
      :jpeg => 'jpegblip',
      :bmp => 'dibitmap0' # device independent bitmap
    }.freeze

    # Supported sizing modes.
    SIZING_MODE_DICTIONARY = {
      # Size the image absolutely according to the given width and height.
      "ABSOLUTE" => "ABSOLUTE",
      # Fit the image in the box specified by the given width and height,
      # preserving the aspect ratio.
      "FIX_ASPECT_RATIO" => "FIX_ASPECT_RATIO"
    }.freeze

     attr_reader :type, :width, :height, :displayed_width, :displayed_height, :sizing_mode, :border
     attr_writer :displayed_width, :displayed_height, :sizing_mode, :border

     # Attempts to extract the type, width, and height of an image using
     # FastImage.
     #
     # @param [String] source the file path to the source image.
     # @return [Array<Object>] a 3-tuple containing the type, width, and height
     #   of the image, respectively (type is a symbol, dimensions in pixels).
     def self.inspect(source)
       type, width, height = nil

       type = TYPE_DICTIONARY[FastImage.type(source)]
       width, height = FastImage.size(source) unless type.nil?

       [type, width, height]
     end # inspect()

     def self.parse_border_array(border)
       case border
       when nil
         []
       when BorderStyle
         [border]
       when Hash
         [BorderStyle.new(border)]
       when Array
         border.collect{ |b| parse_border_array(b) }.flatten.compact
       else
         RTFError.fire("Invalid border #{b}.")
       end
     end

     # This is the constructor for the ImageNode class.
     #
     # @param parent [Node] a reference to the node that owns the new image node.
     # @param source [String, File] a reference to the image source; this must be a String, String URL, or a File.
     # @param id [Integer] a unique 32-bit identifier for the image.
     # @param options [Hash] a hash of options.
     # @option options [String] "width" (nil) the display width of the image in twips (can be a string, see {Utilities.value2twips}).
     # @option options [String] "height" (nil) the display height of the image in twips (can be a string, see {Utilities.value2twips}).
     # @option options [String] "sizing_mode" ("ABSOLUTE") the method used to size the image (see {SIZING_MODE_DICTIONARY}).
     # @raise [RTFError] whenever the image specified is not recognised as
     #   a supported image type, something other than a String or
     #   File or IO is passed as the source parameter or if the
     #   specified source does not exist or cannot be accessed.
     def initialize(parent, source, id, options = {})
        super(parent)
        @source = source
        @id     = id

        # load default options
        options = {
          "width" => nil,
          "height" => nil,
          "sizing_mode" => "ABSOLUTE",
          "border" => nil
        }.merge(options)

        # extract options
        @displayed_width    = Utilities.value2twips(options.delete("width"))
        @displayed_height   = Utilities.value2twips(options.delete("height"))
        @sizing_mode        = SIZING_MODE_DICTIONARY[options.delete("sizing_mode")]
        @border             = self.class.parse_border_array(options.delete("border"))

        # store border colours in colour table
        @border.each do |b|
          b.push_colours(root.colours)
        end

        # Store path to image.
        if @source.is_a?(String)
          begin
            @source = open(@source)
          rescue OpenURI::HTTPError => error
            response = error.io
            RTFError.fire("Could not open '#{@source}'. Server responded with #{response.status.join(',')}.")
          rescue Exception => error
            RTFError.fire("Could not open '#{@source}'. #{error.message}.")
          end # rescue block
        elsif !@source.respond_to?(:each_byte)
          RTFError.fire("A string or object that responds to :each_byte must be supplied - '#{@source}' given.")
        end # unless

        # Attempt to determine image type and dimensions.
        @type, @width, @height = self.class.inspect(@source)
        if @type.nil?
           RTFError.fire("The #{File.basename(@source)} file contains an unknown or unsupported image type.")
        elsif @width.nil? || @height.nil?
          RTFError.fire("Could not determine the dimensions of #{File.basename(@source)}.")
        end # if

        @displayed_width, @displayed_height = size_image
     end # initialize()

     # This method generates the RTF for an ImageNode object.
     def to_rtf
       text  = StringIO.new
       count = 0

       text << '{\pict'
       @border.each{ |b| text << " #{b.prefix(self.root)}" }
       text << "\\picwgoal#{@displayed_width}" if @displayed_width != nil
       text << "\\pichgoal#{@displayed_height}" if @displayed_height != nil
       text << "\\picw#{@width}\\pich#{@height}\\bliptag#{@id}"
       text << "\\#{@type}\n"

       @source.each_byte do |byte|
         hex_str = byte.to_s(16)
         hex_str.insert(0,'0') if hex_str.length == 1
         text << hex_str
         count += 1
         if count == 40
           text << "\n"
           count = 0
         end # if
       end # each_byte
       text << "\n}"

       text.string
     end # to_rtf()

     private

     def size_image
       case @sizing_mode
       when 'ABSOLUTE'
         [@displayed_width, @displayed_height]
       when 'FIX_ASPECT_RATIO'
         width_ratio = @displayed_width ? (@displayed_width.to_f / @width.to_f) : nil
         height_ratio = @displayed_height ? (@displayed_height.to_f / @height.to_f) : nil
         scale_factor = [width_ratio, height_ratio].compact.min

         if scale_factor.nil?
           [@displayed_width, @displayed_height]
         else
           [(@width*scale_factor).to_i, (@height*scale_factor).to_i]
         end
       end # case
     end # size_image()
  end # End of the ImageNode class.
end # module RRTF
