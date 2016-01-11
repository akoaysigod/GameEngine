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
  var uniqueID: String { get }
}

class DrawTree {
  indirect enum Tree {
    case None
    case Node(Tree, GENode?, [GENode]?)
    
    init() { self = .None }
  }
  
  var tree: Tree = .None
  
  //TODO: figure out a better way to do this also,
  //this is broken no time to fix
  //the first guard statement won't work for the root node but fuck it for now
  func addNode(parent: GENode?, node: GENode) {
    let x = 1
    
    var newNode: Tree = .None
    if case let .Node(_, _, nodeChildren) = node.tree.tree {
      newNode = .Node(self.tree, parent, nodeChildren)
    }
    else {
      newNode = .Node(self.tree, parent, nil)
    }
    node.tree.tree = newNode
    
    guard case let .Node(parentTree, parentNode, children) = self.tree else {
      self.tree = .Node(.None, nil, [node])
      return
    }
    
    if var children = children {
      children.append(node)
      
      self.tree = .Node(parentTree, parentNode, children)
    }
  }
}
