//
//  Tree.swift
//  GameEngine
//
//  Created by Anthony Green on 3/5/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

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

  func addNode(node: Node)
  func removeNode<T: Node>(node: T?) -> T?
  func removeFromParent()
  func getAllNodes() -> Nodes
}

public func +(lhs: Node, rhs: Node) {
  lhs.addNode(rhs)
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

  public func removeFromParent() {
    parent?.removeNode(self as? Node)
  }

  public func getAllNodes() -> Nodes {
    let allNodes = nodes.flatMap { $0.getAllNodes() }
    return nodes + allNodes
  }
}
