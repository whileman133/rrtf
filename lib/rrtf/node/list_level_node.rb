module RRTF
  # This class represents a list level, and carries out indenting information
  # and the bullet or number that is prepended to each +ListTextNode+.
  #
  # The class overrides the +list+ method to implement nesting, and provides
  # the +item+ method to add a new list item, the +ListTextNode+.
  class ListLevelNode < CommandNode
    def initialize(parent, template, kind, level=1)
      @template = template
      @kind     = kind
      @level    = template.level_for(level, kind)

      prefix  = '\pard'
      prefix << @level.tabs.map {|tw| "\\tx#{tw}"}.join
      prefix << "\\li#{@level.indent}\\fi-#{@level.indent}"
      prefix << "\\ql\\qlnatural\\pardirnatural\n"
      prefix << "\\ls#{@template.id}\\ilvl#{@level.level-1}\\cf0"

      super(parent, prefix, nil, true, false)
    end

    # Returns the kind of this level, either :bullets or :decimal
    attr_reader :kind

    # Returns the indenting level of this list, from 1 to 9
    def level
      @level.level
    end

    # Creates a new +ListTextNode+ and yields it to the calling block
    def item
      node = ListTextNode.new(self, @level)
      yield node
      self.store(node)
    end

    # Creates a new +ListLevelNode+ to implement nested lists
    def list(kind=@kind)
      node = ListLevelNode.new(self, @template, kind, @level.level+1)
      yield node
      self.store(node)
    end
  end
end
