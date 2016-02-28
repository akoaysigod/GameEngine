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

typealias Nodes = [Node]

protocol Node: class {
  var name: String? { get set }

  var size: CGSize { get set }
  var width: Float { get }
  var height: Float { get }

  var x: Float { get set }
  var y: Float { get set }
  var position: (x: Float, y: Float) { get set }
  var zPosition: Int { get set }
  var z: Float { get }

  var anchorPoint: (x: Float, y: Float) { get set }

  var rotation: Float { get set }

  var scale: (x: Float, y: Float) { get set }
  var xScale: Float { get set }
  var yScale: Float { get set }

  var modelMatrix: GLKMatrix4 { get }

  typealias T
  var parent: T? { get set }
  var nodes: [T] { get set }

  var time: CFTimeInterval { get set }
  func updateWithDelta(delta: CFTimeInterval)

  var action: GEAction? { get set }
  var hasAction: Bool { get }
  func runAction(action: GEAction)
}

extension Node {
  var width: Float {
    return 1.0
  }

  var height: Float {
    return 1.0
  }

  var position: (x: Float, y: Float) {
    get { return (x, y) }
    set {
      x = newValue.0
      y = newValue.1
    } 
  }

  var z: Float {
    return -1.0 * Float(zPosition / Int.max)
  }

  var scale: (x: Float, y: Float) {
    get { return (xScale, yScale) }
    set {
      xScale = newValue.x
      yScale = newValue.y
    }
  }

  var modelMatrix: GLKMatrix4 {
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

  var hasAction: Bool {
    return false
    //let parentHasAction = getSuperParent()?.hasAction ?? false
    //return self.action != nil || parentHasAction
  }

  func runAction(action: GEAction) {
    self.action = action
  }

//    //tree stuff
//  func addNode<T: Node>(node: T) {
//    //node.parent = self
//    //self.nodes.append(node)
//  }
//  
//  func getSuperParent<T: Node>() -> T? {
//    var parent = self.parent
//    while true {
//      if let root = parent?.parent {
//        parent = root
//      }
//      else {
//        return parent
//      }
//    }
//  }
}

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
  var z: Float {
    return -1.0 * Float(self.zPosition) / Float(Int.max)
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
  
  var camera: GECamera!

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

  var parent: GENode?
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
    let parentHasAction = self.getSuperParent()?.hasAction ?? false
    return self.action != nil || parentHasAction
  }

  public func runAction(action: GEAction) {
    self.action = action
  }
  
  //tree stuff
  public func addNode(node: GENode) {
    node.parent = self
    self.nodes.append(node)
  }
  
  func getSuperParent() -> GENode? {
    var parent = self.parent
    while true {
      if let root = parent?.parent {
        parent = root
      }
      else {
        return parent
      }
    }
  }
}
