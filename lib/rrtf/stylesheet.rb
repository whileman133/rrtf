require 'stringio'

module RRTF

  # Class that represents a stylesheet in an RTF document
  class Stylesheet
    # An array of styles associated with the stylesheet
    attr_reader :styles

    # The document to which the stylesheet belongs
    attr_accessor :document

    def initialize(document, options = {})
      @options = {
        "styles" => [],
        "base_style_handle" => 1,
        "base_style_priority" => 100,
        "assign_style_handles" => true,
        "assign_style_priorities" => true
      }.merge(options)
      @document = document
      @next_styles_hash = {}
      @base_styles_hash = {}
      @styles = {}
      add_styles(@options["styles"])
    end

    def add_styles(hash_array)
      hash_array.each { |hash| add_style(hash) }
    end

    def add_style(options)
      style = options.delete("style")
      type = options.delete("type")
      add_options = extract_add_options(options)

      if !style.nil?
        # style object given; add directly
        if !add_style_object(style, add_options)
          RTFError.fire("#{style.to_s} could not be added to the stylesheet (hint: make sure it's a style object).")
        end # if
      elsif !type.nil?
        # style object not given; create based on type
        case type
        when "paragraph"
          add_style_object(ParagraphStyle.new(options), add_options)
        when "character"
          add_style_object(CharacterStyle.new(options), add_options)
        else
          RTFError.fire("Unreconized style type '#{type.to_s}'.")
        end # case
      else
        RTFError.fire("A style type or style object must be specified for each style in a stylesheet.")
      end # if
    end # add_style_from_hash()

    # Converts the stylesheet to its RTF representation
    # NOTE calling to_rtf causes all next styles to be updated (to_rtf "commits"
    # the stylesheet)
    def to_rtf(options = {})
      # load default options
      options = {
        "uglify" => false,
        "base_indent" => 0,
        "child_indent" => 0
      }.merge(options)
      # build line prefixes
      newline_prefix = options["uglify"] ? '' : "\n"
      base_prefix = options["uglify"] ? '' : " "*options["base_indent"]

      # lookup and set next style handles on component styles
      substitute_next_style_handles()
      substitute_base_style_handles()

      rtf = StringIO.new

      rtf << "#{base_prefix}{\\stylesheet"
      @styles.values.each do |style|
        rtf << newline_prefix
        rtf << style.to_rtf(
          document,
          "uglify" => options["uglify"],
          "base_indent" => options["base_indent"]+options["child_indent"]
        )
      end
      rtf << "#{newline_prefix}#{base_prefix}}"

      rtf.string
    end # to_rtf()

    private

    # Strips options used in adding a style to a stylesheet from a hash
    # and returns a subhash containing those options
    def extract_add_options(hash)
      {
        "id" => hash.delete("id"),
        "default" => hash.delete("default") || false,
        "next_style_id" => hash.delete("next_style") || nil,
        "base_style_id" => hash.delete("base_style") || nil,
        "assign_handle" => hash.delete("assign_handle") || @options["assign_style_handles"],
        "assign_priority" => hash.delete("assign_priority") || @options["assign_style_priorities"]
      }
    end # extract_add_options()

    # Adds a style object to the stylesheet
    def add_style_object(style, options = {})
      # load default options
      options = {
        "id" => nil,
        "default" => false,
        "next_style_id" => nil,
        "base_style_id" => nil,
        "assign_handle" => true,
        "assign_priority" => true
      }.merge(options)

      if style.kind_of?(Style)
        unless @styles.values.index(style).nil?
          # style already present in stylesheet
          return true
        end # unless

        # Verify ID is present and does not conflict with another style's ID
        if options["id"].nil? || !options["id"].kind_of?(String) || options["id"].length < 1
          RTFError.fire("All styles in a stylesheet must have unique non-empty string IDs.")
        elsif !@styles[options["id"]].nil?
          RTFError.fire("Multiple styles cannot have the same ID '#{style.id}'.")
        end # if

        # Auto-assign handle to style if nil
        if style.handle.nil? && options["assign_handle"]
          if options["default"]
            # default style takes on the '0' handle
            style.handle = 0
          else
            max_h = @styles.values.collect(&:handle).max
            base_h = @options["base_style_handle"]
            style.handle = (max_h || (base_h - 1)) + 1
          end # if
        end # if

        # Auto-assign priority if nil
        if style.priority.nil? && options["assign_priority"]
          max_p = @styles.values.collect(&:priority).max
          base_p = @options["base_style_priority"]
          style.priority = (max_p || (base_p - 1)) + 1
        end # if

        # Add key in next styles hash if next style given
        unless options["next_style_id"].nil?
          @next_styles_hash[options["id"]] = options["next_style_id"]
        end # unless

        # Add key in base styles hash if next style given
        unless options["base_style_id"].nil?
          @base_styles_hash[options["id"]] = options["base_style_id"]
        end # unless

        # Add style fonts and colours to respective tables
        style.push_colours(document.colours)
        style.push_fonts(document.fonts)

        @styles[options["id"]] = style
        true
      else
        false
      end # if
    end # add()

    # Sets the "next style" handle on each style based on the entries in
    # next_styles_hash (when add is called with the next_style_id option,
    # an entry in the hash is created with the id of the next style; the hash
    # maps the ids of styles to the ids of the corresponding "next styles")
    def substitute_next_style_handles
      @styles.each do |id,style|
        next_style_id = @next_styles_hash[id]
        # skip style if there is not a "next style"
        next if next_style_id.nil?
        # raise error if the specified "next style" is not defined
        if @styles[next_style_id].nil?
          RTFError.fire("'#{next_style_id}' cannot be the next style for '#{id}' because '#{next_style_id}'' has not been added to the stylesheet.")
        end # if
        style.next_style_handle = @styles[next_style_id].handle
      end # styles each
    end # substitute_next_style_handles()

    def substitute_base_style_handles
      @styles.each do |id,style|
        base_style_id = @base_styles_hash[id]
        # skip style if there is not a base style
        next if base_style_id.nil?
        # raise error if the specified base style is not defined
        if @styles[base_style_id].nil?
          RTFError.fire("'#{base_style_id}' cannot be the base style for '#{id}' because '#{base_style_id}'' has not been added to the stylesheet.")
        end # if
        style.based_on_style_handle = @styles[base_style_id].handle
      end # styles each
    end # substitute_next_style_handles()
  end # class Stylesheet

end # module RRTF
