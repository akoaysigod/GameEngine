//
//  NodeTree.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

//fuck rethink this again
public protocol TreeUpdateable: class {
  var nodeTree: NodeTree { get }
  var parent: GENode? { get }
  var nodes: [GENode] { get }
  func addNode(node: GENode)
  func removeNode<T: GENode>(node: T) -> T?
  func removeFromParent()
}

public func ==(rhs: NodeTree, lhs: NodeTree) -> Bool {
  return rhs.hashValue == lhs.hashValue
}

public final class NodeTree: Equatable, Hashable {
  var parent: NodeTree? = nil
  //if root == nil it's dead or the scene
  weak var root: GENode?
  
  //I think using a set will be fine
  var nodes: Set<NodeTree> = Set<NodeTree>()
  
  var uuid = NSUUID().UUIDString
  public var hashValue: Int { return uuid.hashValue }
  
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

  func getAllNodes() -> GENodes  {
    var retNodes = GENodes()
    Array(nodes).forEach { node in
      if let root = node.root {
        retNodes.append(root)
      }
      retNodes += node.getAllNodes()
    }
    return retNodes
  }
}
