module RRTF
  # This class represents a paragraph within an RTF document.
  class ParagraphNode < CommandNode
    def initialize(parent, style=nil)
      prefix = '\pard'
      prefix << style.prefix(parent.root) if style

      super(parent, prefix, '\par')
    end
  end
end
