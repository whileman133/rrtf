module RRTF
  # This class represents an ordered/unordered list within an RTF document.
  #
  # Currently list nodes can contain any type of node, but this behaviour
  # will change in future releases. The class overrides the +list+ method
  # to return a +ListLevelNode+.
  #
  class ListNode < CommandNode
    def initialize(parent)
      prefix  = "\\"

      suffix  = '\pard'
      suffix << ListLevel::ResetTabs.map {|tw| "\\tx#{tw}"}.join
      suffix << '\ql\qlnatural\pardirnatural\cf0 \\'

      super(parent, prefix, suffix, true, false)

      @template = root.lists.new_template
    end

    # This method creates a new +ListLevelNode+ of the given kind and
    # stores it in the document tree.
    #
    # ==== Parameters
    # kind::  The kind of this list level, may be either :bullets or :decimal
    def list(kind)
      self.store ListLevelNode.new(self, @template, kind)
    end
  end
end
