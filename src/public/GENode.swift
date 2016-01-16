//
//  GENode.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

typealias GENodes = [GENode]

public class GENode {
  public var name: String?

  var size = CGSizeZero
  public var width: Float {
    return Float(self.size.width) * self.xScale
  }
  public var height: Float {
    return Float(self.size.height) * self.yScale
  }

  public var x: Float = 0.0
  public var y: Float = 0.0
  public var position: (x: Float, y: Float) {
    get { return (x, y) }
    set {
      self.x = newValue.0
      self.y = newValue.1
    }
  }
  public var zPosition: Int = 0
  private var z: Float {
    return -1.0 * Float(self.zPosition) / 10000.0
  }

  public var rotation: Float = 0.0
  public var scale: Float {
    get { return self.pScale }
    set {
      self.xScale = newValue
      self.yScale = newValue
      self.pScale = newValue
    }
  }
  private var pScale: Float = 1.0
  public var xScale: Float = 1.0
  public var yScale: Float = 1.0

  public var anchorPoint: (x: Float, y: Float) = (x: 0.0, y: 0.0)

  var modelMatrix: GLKMatrix4 {
    let x = self.x - (self.width * self.anchorPoint.x)
    let y = self.y - (self.height * self.anchorPoint.y)

    let xRot = 0.0 - (self.width * self.anchorPoint.x)
    let yRot = 0.0 - (self.height * self.anchorPoint.y)

    let scale = GLKMatrix4MakeScale(self.xScale, self.yScale, 1.0)
    let worldTranslate = GLKMatrix4MakeTranslation(x - xRot, y - yRot, self.z)
    let rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-1 * self.rotation), 0.0, 0.0, 1.0)
    let rotationTranslate = GLKMatrix4MakeTranslation(xRot, yRot, self.z)

    return worldTranslate * rotation * rotationTranslate * scale
  }

  let uniqueID = NSUUID().UUIDString
  
  var nodes = GENodes()
  
  //updating
  var time: CFTimeInterval = 0.0
  func updateWithDelta(delta: CFTimeInterval) {
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
  private var action: GEAction? = nil
  public var hasAction: Bool {
    return self.action != nil
  }

  func runAction(action: GEAction) {
    self.action = action
  }
  
  //tree stuff
  func addNode(node: GENode) {
    self.nodes.append(node)
  }
}
