require 'stringio'
require "rrtf/version"
require 'rtf/font'
require 'rtf/colour'
require 'rtf/style'
require 'rtf/stylesheet'
require 'rtf/information'
require 'rtf/paper'
require 'rtf/node'
require 'rtf/list'

module RRTF
   class RTFError < StandardError
      def initialize(message=nil)
         super(message == nil ? 'No error message available.' : message)
      end

      def RTFError.fire(message=nil)
         raise RTFError.new(message)
      end
   end # class RTFError
end # module RRTF
