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

public typealias Nodes = [Node]

public protocol Node: class {
  var name: String? { get set }

  var camera: GECamera? { get set }

  var size: CGSize { get set }
  var width: Float { get }
  var height: Float { get }

  var x: Float { get set }
  var y: Float { get set }
  var position: (x: Float, y: Float) { get set }
  var zPosition: Int { get set }

  var anchorPoint: (x: Float, y: Float) { get set }

  var rotation: Float { get set }

  var scale: (x: Float, y: Float) { get set }
  var xScale: Float { get set }
  var yScale: Float { get set }

  //var nodeTree: NodeTree { get }

  var time: CFTimeInterval { get set }
  func updateWithDelta(delta: CFTimeInterval)

  var action: GEAction? { get set }
  var hasAction: Bool { get }
  func runAction(action: GEAction)
}

public extension Node {
  public var width: Float {
    return size.w * xScale
  }

  public var height: Float {
    return size.h * yScale
  }

  public var position: (x: Float, y: Float) {
    get { return (x, y) }
    set {
      x = newValue.0
      y = newValue.1
    } 
  }

  private var z: Float {
    return -1.0 * Float(zPosition / Int.max)
  }

  public var scale: (x: Float, y: Float) {
    get { return (xScale, yScale) }
    set {
      xScale = newValue.x
      yScale = newValue.y
    }
  }

  private var modelMatrix: GLKMatrix4 {
    let x = self.x - (width * anchorPoint.x)
    let y = self.y - (height * anchorPoint.y)

    let xRot = 0.0 - (width * anchorPoint.x)
    let yRot = 0.0 - (height * anchorPoint.y)

    let scale = GLKMatrix4MakeScale(xScale, yScale, 1.0)
    let worldTranslate = GLKMatrix4MakeTranslation(x - xRot, y - yRot, z)
    let rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-1 * self.rotation), 0.0, 0.0, 1.0)
    let rotationTranslate = GLKMatrix4MakeTranslation(xRot, yRot, z)

    return worldTranslate * rotation * rotationTranslate * scale
  }

  func updateWithDeltaTime(delta: CFTimeInterval) {
    time += delta

    guard let action = self.action else { return }
    if !action.completed {
      //action.run(self, delta: delta)
    }
  }

  public var hasAction: Bool {
    var performingAction = false
    while let parent = nodeTree.parent?.root {
      if parent.hasAction {
        performingAction = true
        break
      }
    }
    return action != nil || performingAction
  }

  public func runAction(action: GEAction) {
    self.action = action
  }
}

typealias GENodes = [GENode]

public class GENode: Node {
  public var size = CGSizeZero

  public var x: Float = 0.0
  public var y: Float = 0.0

  public var zPosition: Int = 0

  public var rotation: Float = 0.0

  public var xScale: Float = 1.0
  public var yScale: Float = 1.0

  public var anchorPoint: (x: Float, y: Float) = (x: 0.0, y: 0.0)
  
  var camera: GECamera!

  var nodeTree: NodeTree

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
