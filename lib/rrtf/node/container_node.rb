module RRTF
  # This class represents a Node that can contain other Node objects. Its a
  # base class for more specific Node types.
  class ContainerNode < Node
     include Enumerable

     # Children elements of the node
     attr_accessor :children

     # This is the constructor for the ContainerNode class.
     #
     # ==== Parameters
     # parent::     A reference to the parent node that owners the new
     #              ContainerNode object.
     def initialize(parent)
        super(parent)
        @children = []
        @children.concat(yield) if block_given?
     end

     # This method adds a new node element to the end of the list of nodes
     # maintained by a ContainerNode object. Nil objects are ignored.
     #
     # ==== Parameters
     # node::  A reference to the Node object to be added.
     def store(node)
        if !node.nil?
           @children.push(node) if !@children.include?(Node)
           node.parent = self if node.parent != self
        end
        node
     end

     # This method fetches the first node child for a ContainerNode object. If
     # a container contains no children this method returns nil.
     def first
        @children[0]
     end

     # This method fetches the last node child for a ContainerNode object. If
     # a container contains no children this method returns nil.
     def last
        @children.last
     end

     # This method provides for iteration over the contents of a ContainerNode
     # object.
     def each
        @children.each {|child| yield child}
     end

     # This method returns a count of the number of children a ContainerNode
     # object contains.
     def size
        @children.size
     end

     # This method overloads the array dereference operator to allow for
     # access to the child elements of a ContainerNode object.
     #
     # ==== Parameters
     # index::  The offset from the first child of the child object to be
     #          returned. Negative index values work from the back of the
     #          list of children. An invalid index will cause a nil value
     #          to be returned.
     def [](index)
        @children[index]
     end

     # This method generates the RTF text for a ContainerNode object.
     def to_rtf
        RTFError.fire("#{self.class.name}.to_rtf method not yet implemented.")
     end
  end # End of the ContainerNode class.
end
