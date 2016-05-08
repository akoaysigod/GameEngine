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
  var nodes: Nodes { get }
  var parent: Node? { get }
  var superParent: Node? { get }
  var allParents: Nodes { get }
  var allNodes: Nodes { get }

  /// Calculates the combined transform for every parents' `modelMatrix`
  var parentTransform: Mat4 { get }

  func addNode(node: Node)
  func removeNode<T: Node>(node: T?) -> T?
  func removeFromParent()
}

public func +(lhs: Node, rhs: Node) {
  lhs.addNode(rhs)
}

public func -(lhs: Node, rhs: Node) {
  lhs.removeNode(rhs)
}

extension Tree {
  public var superParent: Node? {
    return allParents.last
  }

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
