import Foundation
import simd

/**
 The `Tree` protocol is used by any object that wishes to be part of the tree hiearchy with the root more than likely being a `Scene`.
 
 The basic implementation of this is in the `Node` class where the hiearchy is more or less a group of sets so that a `Node` cannot be added multiple times.
 It would still be possible to add a node to another parent but I'm not sure what will happen or if that even makes sense. 
 Probably best to avoid doing stuff like that.
 */
public protocol Tree: class {
  var hashValue: Int { get }

  /**
   This returns all direct `Node`s of the current `Node`. It's mostly for making other calculations easier.
   */
  var nodes: Nodes { get }

  /// The `Node` directly above the hiearchy of the current `Node`.
  var parent: Node? { get }

  /// Gets all parent `Node`s starting at the current `Node`.
  var allParents: Nodes { get }

  /// Gets all child nodes.
  var allNodes: Nodes { get }

  /// Calculates the combined transform for every parents' `modelMatrix`
  var parentTransform: Mat4 { get }

  /**
   Add a node to the hiearchy.

   - parameter node: The `Node` to add to the tree.
   */
  func add(node: Node)

  /**
   Remove a node from the hiearchy and returns the `Node` removed if it was found.
   The `Node` does not have to be a direct child `Node` of the calling `Node`.

   - parameter node: The `Node` to remove from the hiearchy.

   - returns: The `Node` removed or nil if it wasn't found.
   */
  func remove<T: Node>(node: T?) -> T?

  /**
   Remove calling `Node` from it's parent. 
   By default, this is safe to call on a `Node` that has not been added to a hiearchy.
   */
  func removeFromParent()
}

extension Tree {
  public var allParents: Nodes {
    var ret = Nodes()

    var nextParent = parent
    while let parent = nextParent {
      ret += [parent]
      nextParent = parent.parent
    }
    return ret
  }

  public var parentTransform: Mat4 {
    var ret = Mat4.identity
    allParents.forEach { parent in
      ret *= parent.transform
    }
    return ret
  }

  public var allNodes: Nodes {
    let allNodes = nodes.flatMap { $0.allNodes }
    return nodes + allNodes
  }

  public func removeFromParent() {
    _ = parent?.remove(node: self as? Node)
  }

  public static func +=(lhs: inout Tree, rhs: Node) {
    lhs.add(node: rhs)
  }

  public static func -=(lhs: inout Tree, rhs: Node?) {
    _ = lhs.remove(node: rhs)
  }
}
