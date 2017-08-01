module RRTF
  # This class represents a list item, that can contain text or
  # other nodes. Currently any type of node is accepted, but after
  # more extensive testing this behaviour may change.
  class ListTextNode < CommandNode
    def initialize(parent, level)
      @level  = level
      @parent = parent

      number = siblings_count + 1 if parent.kind == :decimal
      prefix = "{\\listtext#{@level.marker.text_format(number)}}"
      suffix = '\\'

      super(parent, prefix, suffix, false, false)
    end

    private
      def siblings_count
        parent.children.select {|n| n.kind_of?(self.class)}.size
      end
  end
end
