//
//  DrawTree.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import Foundation
import Metal

protocol TreeNode {
  var tree: DrawTree { get }
  var visible: Bool { get }
  var uniqueID: String { get }
}

class DrawTree {
  indirect enum Tree {
    case None
    case Node(Tree, [TreeNode]?)
    
    init() { self = .None }
  }
  
  var tree: Tree = .None
  
  func addNode(node: TreeNode) {
    guard case let .Node(parent, children) = self.tree else {
      self.tree = .Node(.None, [node])
      return
    }
    
    if var children = children {
      var newNode: Tree = .None
      if case let .Node(_, nodeChildren) = node.tree.tree {
        newNode = .Node(self.tree, nodeChildren)
      }
      else {
        newNode = .Node(self.tree, nil)
      }
      node.tree.tree = newNode
      
      children.append(node)
      
      self.tree = .Node(parent, children)
    }
  }
}