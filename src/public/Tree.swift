//
//  Tree.swift
//  GameEngine
//
//  Created by Anthony Green on 3/5/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

public protocol Tree: class {
  var nodes: Nodes { get }
  var parent: Node? { get }
  var superParent: Node? { get }

  func addNode(node: Node)
  func removeNode<T: Node>(node: T?) -> T?
  func removeFromParent()
  func getAllNodes() -> Nodes
}

extension Tree {
  public var superParent: Node? {
    var ret = self.parent
    //hmmm, since I changed this everythings super parent is a Scene so just ignore it
    //or think of a better way to handle this
    while let parent = ret?.parent where !(parent is Scene) {
      ret = parent
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
