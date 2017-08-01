module RRTF
  class LinkNode < CommandNode
    def initialize(parent, url)
      prefix = "\\field{\\*\\fldinst HYPERLINK \"#{url}\"}{\\fldrslt "
      suffix = "}"

      super(parent, prefix, suffix, false)
    end
  end
end
