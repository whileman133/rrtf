require 'rrtf/version'
require 'rrtf/font'
require 'rrtf/colour'
require 'rrtf/style'
require 'rrtf/stylesheet'
require 'rrtf/information'
require 'rrtf/paper'
require 'rrtf/node'
require 'rrtf/list'

module RRTF
    class RTFError < StandardError
      def initialize(message=nil)
        super(message == nil ? 'No error message available.' : message)
      end

      def RTFError.fire(message=nil)
        raise RTFError.new(message)
      end
    end # class RTFError

    class Utilities
      def self.constantize(string)
        string.split('::').inject(Object) {|o,c| o.const_get c}
      end
    end # class Utilities
end # module RRTF
