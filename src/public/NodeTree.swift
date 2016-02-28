//
//  NodeTree.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

protocol TreeUpdateable: class {
  var nodeTree: NodeTree { get }

  var parent: GENode? { get }
  var nodes: [GENode] { get }
  func addNode<T: GENode>(node: T)
  func removeNode<T: GENode>(node: T) -> T?
  func removeFromParent()
}

extension TreeUpdateable {
  var parent: GENode? {
    return nodeTree.parent?.root
  }
  
  var nodes: GENodes {
    return Array(nodeTree.nodes).flatMap { nodeTree -> GENodes in
      if let node = nodeTree.root {
        return [node]
      }
      return []
    }
  }
  
  func addNode<T: TreeUpdateable>(node: T) {
    nodeTree.addNode(node.nodeTree)
  }
  
  func removeNode<T: TreeUpdateable>(node: T) -> T? {
    return nodeTree.removeNode(node.nodeTree)?.root as? T
  }
  
  func removeFromParent() {
    nodeTree.parent?.removeNode(nodeTree)
    nodeTree.parent = nil
  }
}

func ==(rhs: NodeTree, lhs: NodeTree) -> Bool {
  return rhs.hashValue == lhs.hashValue
}

final class NodeTree: Equatable, Hashable {
  var parent: NodeTree? = nil
  //if root == nil it's dead or the scene
  weak var root: GENode?
  
  //I think using a set will be fine
  var nodes: Set<NodeTree> = Set<NodeTree>()
  
  var hashValue: Int { return NSUUID().UUIDString.hashValue }
  
  var superParent: NodeTree? {
    var parent = self.parent
    while let root = parent?.parent {
      parent = root
    }
    return parent
  }
  
  init(root: GENode?) {
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
