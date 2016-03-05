//
//  GETree.swift
//  GameEngine
//
//  Created by Anthony Green on 3/5/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

public protocol GETree: class {
  var nodes: GENodes { get }
  var parent: GENode? { get }
  var superParent: GENode? { get }

  func addNode(node: GENode)
  func removeNode<T: GENode>(node: T?) -> T?
  func removeFromParent()
  func getAllNodes() -> GENodes
}

extension GETree {
  public var superParent: GENode? {
    var ret = self.parent
    while let parent = parent?.parent {
      ret = parent
    }
    return ret
  }

  public func removeFromParent() {
    parent?.removeNode(self as? GENode)
  }

  public func getAllNodes() -> GENodes {
    let allNodes = nodes.flatMap { $0.getAllNodes() }
    return nodes + allNodes
  }
}
