//
//  GENode.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import UIKit

public typealias GENodes = [GENode]

public func ==(rhs: GENode, lhs: GENode) -> Bool {
   return rhs.hashValue == lhs.hashValue
}

public class GENode: GENodeGeometry, GETree, Equatable, Hashable {
  public var name: String? = nil
  
  public var size: CGSize {
    didSet {
      updateSize()
    }
  }

  public var anchorPoint: (x: Float, y: Float) = (x: 0.0, y: 0.0)

  public var x: Float = 0.0
  public var y: Float = 0.0

  public var zPosition: Int = 0

  public var rotation: Float = 0.0

  public var xScale: Float = 1.0
  public var yScale: Float = 1.0
  
  public var camera: GECamera!

  //tree related
  private var uuid = NSUUID().UUIDString
  public var hashValue: Int { return uuid.hashValue }
  private var nodeSet = Set<GENode>()
  public var nodes: GENodes {
    return Array(nodeSet)
  }
  public private(set) var parent: GENode? = nil

  init(size: CGSize = .zero) {
    self.size = size
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
    var performingAction = parent?.hasAction ?? false
    while let parent = parent?.parent where !performingAction {
      guard parent.hasAction else { continue }
      performingAction = true
    }
    return action != nil || performingAction
  }

  func runAction(action: GEAction) {
    self.action = action
  }

  //tree stuff
  public func addNode(node: GENode) {
    node.camera = camera
    node.parent = self
    nodeSet.insert(node)
  }
  
  public func removeNode<T: GENode>(node: T?) -> T? {
    guard let node = node else { return nil }
    let optNode = nodeSet.remove(node) as? T
    optNode?.parent = nil
    return optNode
  }
}

extension GENode: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(self.dynamicType)"
    return name
  }
}
