//
//  Tree.swift
//  GameEngine
//
//  Created by Anthony Green on 3/5/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

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
  func addNode(node: Node)

  /**
   Remove a node from the hiearchy and returns the `Node` removed if it was found.
   The `Node` does not have to be a direct child `Node` of the calling `Node`.

   - parameter node: The `Node` to remove from the hiearchy.

   - returns: The `Node` removed or nil if it wasn't found.
   */
  func removeNode<T: Node>(node: T?) -> T?

  /**
   Remove calling `Node` from it's parent. 
   By default, this is safe to call on a `Node` that has not been added to a hiearchy.
   */
  func removeFromParent()
}

public func +(lhs: Node, rhs: Node) {
  lhs.addNode(rhs)
}

public func -(lhs: Node, rhs: Node) {
  lhs.removeNode(rhs)
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
    if parent is Scene {
      return Mat4.identity
    }

    /*
     lol I don't know why I complicated that so much.
     
     TODO: cache these calculations somehow, deeply nested nodes probably don't need to update based on the parents
           if the parents aren't updating. This could possibly be a lot of calculation for no reason.
    */
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
    parent?.removeNode(self as? Node)
  }
}
