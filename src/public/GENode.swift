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



typealias GENodes = [GENode]

public class GENode: GENodeGeometry {
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

  var nodeTree: NodeTree!

  init() {
    self.nodeTree = NodeTree(root: self)
  }
  
  //updating
  public var time: CFTimeInterval = 0.0
  //tmp
  public func updateWithDelta(delta: CFTimeInterval) {
    self.time += delta

    guard let action = self.action else { return }
    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  //action related
  public var action: GEAction? = nil
}
