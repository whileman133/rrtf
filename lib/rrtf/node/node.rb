module RRTF
  # This class represents an element within an RTF document. The class provides
  # a base class for more specific node types.
  class Node
     # Node parent.
     attr_accessor :parent

     # Constructor for the Node class.
     #
     # ==== Parameters
     # parent::  A reference to the Node that owns the new Node. May be nil
     #           to indicate a base or root node.
     def initialize(parent)
        @parent = parent
     end

     # This method retrieves a Node objects previous peer node, returning nil
     # if the Node has no previous peer.
     def previous_node
        peer = nil
        if !parent.nil? and parent.respond_to?(:children)
           index = parent.children.index(self)
           peer  = index > 0 ? parent.children[index - 1] : nil
        end
        peer
     end

     # This method retrieves a Node objects next peer node, returning nil
     # if the Node has no previous peer.
     def next_node
        peer = nil
        if !parent.nil? and parent.respond_to?(:children)
           index = parent.children.index(self)
           peer  = parent.children[index + 1]
        end
        peer
     end

     # This method is used to determine whether a Node object represents a
     # root or base element. The method returns true if the Nodes parent is
     # nil, false otherwise.
     def is_root?
        @parent.nil?
     end

     # This method traverses a Node tree to locate the root element.
     def root
        node = self
        node = node.parent while !node.parent.nil?
        node
     end
  end # End of the Node class.
end
