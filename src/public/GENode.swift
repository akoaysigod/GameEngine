//
//  GENode.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

public typealias GENodes = [GENode]

public class GENode: GENodeGeometry, TreeUpdateable {
  public var name: String? = nil
  
  public var size = CGSizeZero

  public var anchorPoint: (x: Float, y: Float) = (x: 0.0, y: 0.0)

  public var x: Float = 0.0
  public var y: Float = 0.0

  public var zPosition: Int = 0

  public var rotation: Float = 0.0

  public var xScale: Float = 1.0
  public var yScale: Float = 1.0
  
  public var camera: GECamera!

  init() {
    self.nodeTree = NodeTree(root: nil)
    self.nodeTree.root = self
  }
  
  //updating
  private(set) var time: CFTimeInterval = 0.0
  func updateWithDelta(delta: CFTimeInterval) {
    time += delta

    guard let action = self.action else { return }
    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  //actions
  public var action: GEAction? = nil
  var hasAction: Bool {
    var performingAction = false
    while let parent = nodeTree.parent?.root {
      if parent.hasAction {
        performingAction = true
        break
      }
    }
    return action != nil || performingAction
  }

  func runAction(action: GEAction) {
    self.action = action
  }

  //node tree
  public var nodeTree: NodeTree

  public var parent: GENode? {
    return nodeTree.parent?.root
  }
  
  public var nodes: GENodes {
    return Array(nodeTree.nodes).flatMap { nodeTree -> GENodes in
      if let node = nodeTree.root {
        return [node]
      }
      return []
    }
  }
  
  public func addNode(node: GENode) {
    nodeTree.addNode(node.nodeTree)
  }
  
  public func removeNode<T: GENode>(node: T) -> T? {
    return nodeTree.removeNode(node.nodeTree)?.root as? T
  }
  
  public func removeFromParent() {
    nodeTree.parent?.removeNode(nodeTree)
    nodeTree.parent = nil
  }
}

extension GENode: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(self.dynamicType)"
    return name
  }
}
