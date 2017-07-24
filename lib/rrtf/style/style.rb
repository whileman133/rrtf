# This is a parent class that all style classes will derive from.
class RRTF::Style
   attr_accessor :handle, :name, :priority, :primary, :additive,
                 :next_style_handle, :auto_update, :based_on_style_handle

   # Constructor for the style class.
   #
   # ===== Parameters
   # options:: A hashmap of options for the style. Used only in stylesheet.
   #   name::        Human-readable name for the style DEFAULT nil
   #   id::          ID for the style (for use in code) DEFAULT nil
   #   handle::      A 16-bit integer that identifies the style in a document
   #                 DEFAULT nil
   #   flow::        The character flow (Style::LEFT_TO_RIGHT or Style::RIGHT_TO_LEFT)
   #                 DEFAULT LEFT_TO_RIGHT
   #   primary::     A Boolean indicating whether or not this style is a
   #                 primary or "quick" style
   #   additive::    A Boolean indicating whether or not this style is
   #                 additive DEFAULT false
   def initialize(options = {})
     # load default options
     options = {
       "name" => nil,
       "handle" => nil,
       "priority" => nil,
       "flow" => 'LEFT_TO_RIGHT',
       "primary" => false,
       "additive" => false,
       "next_style_handle" => nil,
       "auto_update" => false,
       "based_on_style_handle" => nil
     }.merge(options)

     @handle = options.delete("handle")
     @name = options.delete("name")
     @priority = options.delete("priority")
     @flow = options.delete("flow")
     @primary = options.delete("primary")
     @additive = options.delete("additive")
     @next_style_handle = options.delete("next_style_handle")
     @auto_update = options.delete("auto_update")
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
