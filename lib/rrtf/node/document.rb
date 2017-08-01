module RRTF
  # This class represents an RTF document. In actuality it is just a
  # specialised Node type that cannot be assigned a parent and that holds
  # document font, colour and information tables.
  # @author Peter Wood
  # @author Wesley Hileman
  class Document < CommandNode
    # A hash mapping character set string constants to their RTF counterparts.
    # @return [Hash<String, Symbol>] the RTF character set dictionary.
     CS_DICTIONARY = {
       "ANSI"    => :ansi,
       "MAC"     => :mac,
       "PC"      => :pc,
       "PCA"     => :pca
     }.freeze

     # A hash mapping langauge set string constants to their RTF counterparts.
     # @return [Hash<String, Integer>] the RTF langauge setting dictionary.
     LS_DICTIONARY = {
       "AFRIKAANS"                   => 1078,
       "ARABIC"                      => 1025,
       "CATALAN"                     => 1027,
       "CHINESE_TRADITIONAL"         => 1028,
       "CHINESE_SIMPLIFIED"          => 2052,
       "CZECH"                       => 1029,
       "DANISH"                      => 1030,
       "DUTCH"                       => 1043,
       "DUTCH_BELGIAN"               => 2067,
       "ENGLISH_UK"                  => 2057,
       "ENGLISH_US"                  => 1033,
       "FINNISH"                     => 1035,
       "FRENCH"                      => 1036,
       "FRENCH_BELGIAN"              => 2060,
       "FRENCH_CANADIAN"             => 3084,
       "FRENCH_SWISS"                => 4108,
       "GERMAN"                      => 1031,
       "GERMAN_SWISS"                => 2055,
       "GREEK"                       => 1032,
       "HEBREW"                      => 1037,
       "HUNGARIAN"                   => 1038,
       "ICELANDIC"                   => 1039,
       "INDONESIAN"                  => 1057,
       "ITALIAN"                     => 1040,
       "JAPANESE"                    => 1041,
       "KOREAN"                      => 1042,
       "NORWEGIAN_BOKMAL"            => 1044,
       "NORWEGIAN_NYNORSK"           => 2068,
       "POLISH"                      => 1045,
       "PORTUGUESE"                  => 2070,
       "POTUGUESE_BRAZILIAN"         => 1046,
       "ROMANIAN"                    => 1048,
       "RUSSIAN"                     => 1049,
       "SERBO_CROATIAN_CYRILLIC"     => 2074,
       "SERBO_CROATIAN_LATIN"        => 1050,
       "SLOVAK"                      => 1051,
       "SPANISH_CASTILLIAN"          => 1034,
       "SPANISH_MEXICAN"             => 2058,
       "SWAHILI"                     => 1089,
       "SWEDISH"                     => 1053,
       "THAI"                        => 1054,
       "TURKISH"                     => 1055,
       "UNKNOWN"                     => 1024,
       "VIETNAMESE"                  => 1066
     }.freeze

     # Attribute accessor.
     attr_reader :fonts, :lists, :colours, :information, :character_set,
                 :language, :properties, :stylesheet

     # Attribute mutator.
     attr_writer :character_set, :language, :stylesheet


     # Represents an entire RTF document.
     # @note The "suppress_system_styles" option is ignored by most RTF platforms including Word and LibreOffice.
     # @see DocumentProperties#initialize DocumentProperties#initialize for available document properties.
     # @see Stylesheet#add_style Stylesheet#initialize for available stylesheet options.
     #
     # @param [Hash<String, Object>] options the options to use in creating the document.
     # @option options [String, Font] "default_font" ("SWISS:Helvetica") a font object OR string encapsulating the default font to be used by the document (see {Font.from_string} for string format).
     # @option options [String] "character_set" ("ANSI") the character set to be applied to the document (see {CS_DICTIONARY} for valid values).
     # @option options [String] "language" ("ENGLISH_US") the language setting to be applied to the document (see {LS_DICTIONARY} for valid values).
     # @option options [Boolean] "suppress_system_styles" (false) whether or not to suppress styles provided in the host platform (adds the \noqfpromote control word before stylesheet definition).
     # @option options [DocumentProperties] "document_properties" (DocumentProperties.new) a DocumentProperties object OR options hash encapsulating the properties to be applied to the document.
     # @option options [Array, Hash, Stylesheet] "stylesheet" (nil) a Stylesheet object OR array of style hashes OR hash of stylesheet options with which to use as or construct the stylesheet for the document.
     def initialize(options = {})
       # load default options
       options = {
          "default_font" => "SWISS:Helvetica",
          "document_properties" => DocumentProperties.new,
          "character_set" => "ANSI",
          "language" => "ENGLISH_US",
          "suppress_system_styles" => false,
          "stylesheet" => nil
       }.merge(options)

        super(nil, '\rtf1')

        # parse font
        font = options.delete("default_font")
        case font
        when Font
        when String
          font = Font.from_string(font)
        else
          RTFError.fire("Unreconized font format #{font.class.to_s}")
        end # case

        # parse document properties
        properties = options.delete("document_properties")
        case properties
        when DocumentProperties
        when Hash
          properties = DocumentProperties.new(properties)
        else
          RTFError.fire("Unreconized document style format #{font.class.to_s}")
        end # case

        # parse character set
        cs_string = options.delete("character_set")
        cs_val = CS_DICTIONARY[cs_string]
        if cs_val.nil?
          RTFError.fire("Unreconized character set '#{cs_string}'.")
        end # if

        # parse language setting
        ls_string = options.delete("language")
        ls_val = LS_DICTIONARY[ls_string]
        if ls_val.nil?
          RTFError.fire("Unreconized language '#{ls_string}'.")
        end # if

        @fonts         = FontTable.new(font)
        @lists         = ListTable.new
        @default_font  = 0
        @colours       = ColourTable.new
        @information   = Information.new
        @character_set = cs_val
        @language      = ls_val
        @properties    = properties
        @headers       = [nil, nil, nil, nil]
        @footers       = [nil, nil, nil, nil]
        @id            = 0

        # parse stylesheet (must be done after font and colour tables are
        # initialized since declared styles may push fonts/colours onto the
        # tables)
        stylesheet = options.delete("stylesheet")
        case stylesheet
        when Stylesheet
          stylesheet.document = self
        when Array
          stylesheet = Stylesheet.new(self, "styles" => stylesheet)
        when Hash
          stylesheet = Stylesheet.new(self, stylesheet)
        else
          RTFError.fire("Unreconized stylesheet format #{font.class.to_s}")
        end unless stylesheet.nil? # case

        @stylesheet    = stylesheet
        # additional options
        @options       = options
     end

     # This method provides a method that can be called to generate an
     # identifier that is unique within the document.
     def get_id
        @id += 1
        Time.now().strftime('%d%m%y') + @id.to_s
     end

     # Attribute accessor.
     def default_font
        @fonts[@default_font]
     end

     # This method assigns a new header to a document. A Document object can
     # have up to four header - a default header, a header for left pages, a
     # header for right pages and a header for the first page. The method
     # checks the header type and stores it appropriately.
     #
     # ==== Parameters
     # header::  A reference to the header object to be stored. Existing header
     #           objects are overwritten.
     def header=(header)
        if header.type == HeaderNode::UNIVERSAL
           @headers[0] = header
        elsif header.type == HeaderNode::LEFT_PAGE
           @headers[1] = header
        elsif header.type == HeaderNode::RIGHT_PAGE
           @headers[2] = header
        elsif header.type == HeaderNode::FIRST_PAGE
           @headers[3] = header
        end
     end

     # This method assigns a new footer to a document. A Document object can
     # have up to four footers - a default footer, a footer for left pages, a
     # footer for right pages and a footer for the first page. The method
     # checks the footer type and stores it appropriately.
     #
     # ==== Parameters
     # footer::  A reference to the footer object to be stored. Existing footer
     #           objects are overwritten.
     def footer=(footer)
        if footer.type == FooterNode::UNIVERSAL
           @footers[0] = footer
        elsif footer.type == FooterNode::LEFT_PAGE
           @footers[1] = footer
        elsif footer.type == FooterNode::RIGHT_PAGE
           @footers[2] = footer
        elsif footer.type == FooterNode::FIRST_PAGE
           @footers[3] = footer
        end
     end

     # This method fetches a header from a Document object.
     #
     # ==== Parameters
     # type::  One of the header types defined in the header class. Defaults to
     #         HeaderNode::UNIVERSAL.
     def header(type=HeaderNode::UNIVERSAL)
        index = 0
        if type == HeaderNode::LEFT_PAGE
           index = 1
        elsif type == HeaderNode::RIGHT_PAGE
           index = 2
        elsif type == HeaderNode::FIRST_PAGE
           index = 3
        end
        @headers[index]
     end

     # This method fetches a footer from a Document object.
     #
     # ==== Parameters
     # type::  One of the footer types defined in the footer class. Defaults to
     #         FooterNode::UNIVERSAL.
     def footer(type=FooterNode::UNIVERSAL)
        index = 0
        if type == FooterNode::LEFT_PAGE
           index = 1
        elsif type == FooterNode::RIGHT_PAGE
           index = 2
        elsif type == FooterNode::FIRST_PAGE
           index = 3
        end
        @footers[index]
     end

     # Loads a stylesheet for the document from an array of hashmaps
     # representing styles
     def load_stylesheet(hashmap_array)
       @stylesheet = Stylesheet.new(self, hashmap_array)
     end

     # Attribute mutator.
     #
     # ==== Parameters
     # font::  The new default font for the Document object.
     def default_font=(font)
        @fonts << font
        @default_font = @fonts.index(font)
     end

     # This method provides a short cut for obtaining the Paper object
     # associated with a Document object.
     def paper
        @style.paper
     end

     # This method overrides the parent=() method inherited from the
     # CommandNode class to disallow setting a parent on a Document object.
     #
     # ==== Parameters
     # parent::  A reference to the new parent node for the Document object.
     #
     # ==== Exceptions
     # RTFError::  Generated whenever this method is called.
     def parent=(parent)
        RTFError.fire("Document objects may not have a parent.")
     end

     # This method inserts a page break into a document.
     def page_break
        self.store(CommandNode.new(self, '\page', nil, false))
        nil
     end

     # This method fetches the width of the available work area space for a
     # typical Document object page.
     def body_width
        @style.body_width
     end

     # This method fetches the height of the available work area space for a
     # a typical Document object page.
     def body_height
        @style.body_height
     end

     # This method generates the RTF text for a Document object.
     def to_rtf
        text = StringIO.new

        text << "{#{prefix}\\#{@character_set.id2name}"
        text << "\\deff#{@default_font}"
        text << "\\deflang#{@language}" if !@language.nil?
        text << "\\plain\\fs24\\fet1"
        text << "\n#{@fonts.to_rtf}"
        text << "\n#{@colours.to_rtf}" if @colours.size > 0
        text << "\n\\noqfpromote" if @options["suppress_system_styles"]
        text << "\n#{@stylesheet.to_rtf}" if !@stylesheet.nil?
        text << "\n#{@information.to_rtf}"
        text << "\n#{@lists.to_rtf}"
        if @headers.compact != []
           text << "\n#{@headers[3].to_rtf}" if !@headers[3].nil?
           text << "\n#{@headers[2].to_rtf}" if !@headers[2].nil?
           text << "\n#{@headers[1].to_rtf}" if !@headers[1].nil?
           if @headers[1].nil? or @headers[2].nil?
              text << "\n#{@headers[0].to_rtf}"
           end
        end
        if @footers.compact != []
           text << "\n#{@footers[3].to_rtf}" if !@footers[3].nil?
           text << "\n#{@footers[2].to_rtf}" if !@footers[2].nil?
           text << "\n#{@footers[1].to_rtf}" if !@footers[1].nil?
           if @footers[1].nil? or @footers[2].nil?
              text << "\n#{@footers[0].to_rtf}"
           end
        end
        text << "\n#{@properties.to_rtf}" if !@properties.nil?
        self.each {|entry| text << "\n#{entry.to_rtf}"}
        text << "\n}"

        text.string
     end
  end # End of the Document class.
end # module RRTF
