module RRTF
  # This class represents a geometry object (shape or text box) within an RTF
  # document.
  # @author Wesley Hileman
  # @since 1.0.0
  class GeometryNode < CommandNode

    attr_reader :properties

    # Constructor for the GeometryNode class.
    #
    # @param [Hash, GeometryProperties] properties a hash or GeometryProperties
    #   object specifying the properties of the geometry object.
    def initialize(parent, properties = nil)
      case properties
      when Hash
        @properties = GeometryProperties.new(properties)
      when GeometryProperties
        @properties = properties
      else
        RTFError.fire("Invalid geometry properties '#{properties}'.")
      end unless properties.nil?

      prefix = '{\shp{\*\shpinst'
      prefix << @properties.to_rtf unless properties.nil?

      super(parent, prefix, '}}', false, false)
    end

    def to_rtf
      text = StringIO.new

      text << @prefix

      unless self.size() == 0
        text << '{\shptxt'
        self.each do |entry|
           text << "\n"
           text << entry.to_rtf
        end # each
        text << '}'
      end # unless

      text << @suffix

      text.string
    end

    # Overrides the {CommandNode#geometry} method to prevent geometry objects
    # from being nested in other geometry objects.
    #
    # @raise [RTFError] whenever called.
    def geometry(properties = nil)
      RTFError.fire("Cannot place a geometry object inside of another.")
    end

    # Overrides the {CommandNode#<<} method to prevent text from being added
    # to geometry objects directly. Calls {#paragraph} instead.
    #
    # @raise [RTFError] whenever called.
    def <<(text)
      self.paragraph << text
    end
  end # class GeometryNode
end # module RRTF
