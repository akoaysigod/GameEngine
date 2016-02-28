//
//  NodeTree.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

protocol Tree {
  var nodeTree: NodeTree { get }
}

public protocol TreeUpdateable: Tree {
  var parent: Node? { get }
  var nodes: [Node] { get }
  func addNode<T: Node>(node: T)
  func removeNode<T: Node>(node: T) -> T?
  func removeFromParent()
}

public extension TreeUpdateable {
  public var parent: Node? {
    return nodeTree.parent?.root
  }

  public var nodes: Nodes {
    return Array(nodeTree.nodes).flatMap { nodeTree -> Nodes in
      if let node = nodeTree.root {
        return [node]
      }
      return []
    }
  }
  
  public func addNode<T: Tree>(node: T) {
    nodeTree.addNode(node.nodeTree)
  }

  public func removeNode<T: Tree>(node: T) -> T? {
    return nodeTree.removeNode(node.nodeTree)?.root as? T
  }

  public func removeFromParent() {
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
