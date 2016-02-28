//
//  NodeTree.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

func ==(rhs: NodeTree, lhs: NodeTree) -> Bool {
  return rhs.hashValue == lhs.hashValue
}

class NodeTree: Equatable, Hashable {
  var parent: NodeTree? = nil
  //if root == nil it's dead or the scene
  weak var root: Node?

  //I think using a set will be fine
  var nodes: Set<NodeTree> = Set<NodeTree>()

  var hashValue = NSUUID().UUIDString.hashValue

  var superParent: NodeTree? {
    var parent = self.parent
    while let root = parent?.parent {
      parent = root
    }
    return parent
  }

  init(root: Node?) {
    self.root = root
  }

  func addNode(node: NodeTree) {
    node.parent = self
    nodes.insert(node)
  }

  func removeNode(node: NodeTree) -> NodeTree? {
    return nodes.remove(node)
  }
}