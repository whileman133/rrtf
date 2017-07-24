# This is a parent class that all style classes will derive from.
class RRTF::Style
   attr_accessor :handle, :name, :priority, :primary, :additive,
                 :next_style_handle, :auto_update, :based_on_style_handle,
                 :hidden

   # Constructor for the style class.
   #
   # @param [Hash] options
   # @option options [String] "name" (nil) human-readable name for the style.
   # @option options [Integer] "handle" (nil) 16-bit integer that identifies the style in a document.
   # @option options [Integer] "next_style_handle" (nil) 16-bit integer that identifies the next style for this style.
   # @option options [Integer] "based_on_style_handle" (nil) 16-bit integer that identifies the base style for this style.
   # @option options [Integer] "priority" (nil) 16-bit integer that indicates the ordering of the style among other styles in a document.
   # @option options [Boolean] "primary" (false) whether or not this style is a primary or "quick" style.
   # @option options [Boolean] "additive" (false) whether or not this character style is additive to the current paragraph style.
   # @option options [Boolean] "auto_update" (false) whether or not this style should be updated when any node to which the style is applied is updated.
   # @option options [Boolean] "hidden" (false) whether or not the style should be hidden.
   def initialize(options = {})
     # load default options
     options = {
       "name" => nil,
       "handle" => nil,
       "priority" => nil,
       "primary" => false,
       "additive" => false,
       "next_style_handle" => nil,
       "auto_update" => false,
       "based_on_style_handle" => nil,
       "hidden" => false
     }.merge(options)

     @handle = options.delete("handle")
     @name = options.delete("name")
     @priority = options.delete("priority")
     @flow = options.delete("flow")
     @primary = options.delete("primary")
     @additive = options.delete("additive")
     @next_style_handle = options.delete("next_style_handle")
     @auto_update = options.delete("auto_update")
     @hidden = options.delete("hidden")
   end

   # Constructs an RTF identifier for the style.
   # (override in derived classes as needed)
   def styledef
     nil
   end

   def stylename
     name
   end

   # Constructs the RTF formatting representing the style.
   # (override in derived classes as needed)
   def to_rtf(document)
     nil
   end

   # This method retrieves the command prefix text associated with a Style
   # object. This method always returns nil and should be overridden by
   # derived classes as needed.
   def prefix(document)
      nil
   end

   def rtf_formatting
     nil
   end

   # This method retrieves the command suffix text associated with a Style
   # object. This method always returns nil and should be overridden by
   # derived classes as needed.
   def suffix(document)
      nil
   end

   # Used to determine if the style applies to characters. This method always
   # returns false and should be overridden by derived classes as needed.
   def is_character_style?
      false
   end

   # Used to determine if the style applies to paragraphs. This method always
   # returns false and should be overridden by derived classes as needed.
   def is_paragraph_style?
      false
   end

   # Used to determine if the style applies to documents. This method always
   # returns false and should be overridden by derived classes as needed.
   def is_document_style?
      false
   end

   # Used to determine if the style applies to tables. This method always
   # returns false and should be overridden by derived classes as needed.
   def is_table_style?
      false
   end
end # End of the style class.
