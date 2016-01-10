//
//  GECamera.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import GLKit

public class GECamera {
  private var cameraMatrix: GLKMatrix4 {
    return GLKMatrix4Translate(GLKMatrix4Identity, self.x, self.y, 0.0)
  }

  private var projectionMatrix: GLKMatrix4 {
    let xRow = GLKVector4(v: (2.0 / rsl * zoom, 0.0, 0.0, -ral / rsl))
    let yRow = GLKVector4(v: (0.0, 2.0 / tsb * zoom, 0.0, -tab / tsb))
    let zRow = GLKVector4(v: (0.0, 0.0, -2.0 / fsn, -fan / fsn))
    let wRow = GLKVector4(v: (0.0, 0.0, 0.0, 1.0))
    return GLKMatrix4MakeWithRows(xRow, yRow, zRow, wRow)
  }

  var data: [Float] {
    return self.cameraMatrix.data + self.projectionMatrix.data
  }

  var dataSize: Int {
    return self.data.count * FloatSize
  }

  private let left: Float = 0.0
  private let right: Float
  private let bottom: Float = 0.0
  private let top: Float
  private let near: Float = -1.0
  private let far: Float = 1.0

  private var ral: Float { return right + left }
  private var rsl: Float { return right - left }
  private var tab: Float { return top + bottom }
  private var tsb: Float { return top - bottom }
  private var fan: Float { return far + near }
  private var fsn: Float { return far - near }

  public var x: Float = 0.0
  public var y: Float = 0.0
  var zoom: Float = 1.0

  init(size: CGSize) {
    self.right = Float(size.width)
    self.top = Float(size.height)
  }

  func multiplyMatrices(modelViewMatrix: GLKMatrix4) -> GLKMatrix4 {
    return self.projectionMatrix * self.cameraMatrix * modelViewMatrix
  }
}
