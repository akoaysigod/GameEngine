//
//  NodeGeometry.swift
//  GameEngine
//
//  Created by Anthony Green on 2/28/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd
import UIKit

/**
 The `NodeGeometry` protocol is used to give an object enough information to be placed in a scene and possibly rendered. 
 
 - note: Any rendered `Node` must have the camera property be non-nil. I'm still trying to figure out a nicer way to enforce this.
 */
public protocol NodeGeometry: class {
  var camera: Camera? { get set }

  var size: CGSize { get set }
  var width: Float { get }
  var height: Float { get }

  var anchorPoint: (x: Float, y: Float) { get set }

  var x: Float { get set }
  var y: Float { get set }
  var position: (x: Float, y: Float) { get set }
  var zPosition: Int { get set }

  var rotation: Float { get set }

  var scale: (x: Float, y: Float) { get set }
  var xScale: Float { get set }
  var yScale: Float { get set }

  var modelMatrix: Mat4 { get }

  /**
   This function updates the actual geometry size of the vertices. It does not scale.
   It's default implementation is in `Renderable`.
   */
  func updateSize()
}

public extension NodeGeometry {
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

  var z: Float {
    return -1.0 * Float(zPosition / Int.max)
  }

  public var scale: (x: Float, y: Float) {
    get { return (xScale, yScale) }
    set {
      xScale = newValue.x
      yScale = newValue.y
    }
  }

  public var modelMatrix: Mat4 {
    let x = self.x - (width * anchorPoint.x)
    let y = self.y - (height * anchorPoint.y)

    let xRot = 0.0 - (width * anchorPoint.x)
    let yRot = 0.0 - (height * anchorPoint.y)

    let scale = Mat4.scale(xScale, yScale)
    let worldTranslate = Mat4.translate(x - xRot, y - yRot, z)
    let rotation = Mat4.rotate(-1 * self.rotation)
    let rotationTranslate = Mat4.translate(xRot, yRot, z)

    return worldTranslate * rotation * rotationTranslate * scale
  }
}
