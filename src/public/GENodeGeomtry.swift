//
//  GENodeGeometry.swift
//  GameEngine
//
//  Created by Anthony Green on 2/28/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit

public protocol GENodeGeometry: class {
  var camera: GECamera! { get set }

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

  var modelMatrix: GLKMatrix4 { get }
}

public extension GENodeGeometry {
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

  public var modelMatrix: GLKMatrix4 {
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
}