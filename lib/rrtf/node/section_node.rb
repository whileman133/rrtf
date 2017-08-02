module RRTF
  # This class represents a section within an RTF document. Section nodes
  # do not contain other nodes; instead, they mark the start of a new section.
  # @author Wesley Hileman
  class SectionNode < CommandNode
    def initialize(parent, style=nil)
      prefix = '\sect\sectd'
      prefix << style.prefix(parent.root) unless style.nil?

      super(parent, prefix, '', true, false)
    end

    # Overrides {ContainerNode#store} to prevent child nodes from being
    # added to sections.
    #
    # @raise [RTFError] whenever called.
    def store(node)
      RTFError.fire("Cannot add child nodes to section nodes: tried to add #{node}.")
    end
  end
end
