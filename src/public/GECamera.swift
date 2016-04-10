//
//  GECamera.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import GLKit
import simd
import UIKit

public class GECamera: GENode {
  private var cameraMatrix: Mat4 {
    return Mat4.translate(x, y)
    //return GLKMatrix4Translate(GLKMatrix4Identity, x, y, 0.0)
  }

  private var projectionMatrix: Mat4 {
    let xRow = Vec4(x: 2.0 / rsl * zoom, y: 0.0, z: 0.0, w: 0.0)
    let yRow = Vec4(x: 0.0, y: 2.0 / tsb * zoom, z: 0.0, w: 0.0)
    let zRow = Vec4(x: 0.0, y: 0.0, z: -2.0 / fsn, w: 0.0)
    let wRow = Vec4(x: -ral / rsl, y: -tab / tsb, z: -fan / fsn, w: 1.0)

//    let xRow = Vec4(x: 2.0 / rsl * zoom, y: 0.0, z: 0.0, w: -ral / rsl)
//    let yRow = Vec4(x: 0.0, y: 2.0 / tsb * zoom, z: 0.0, w: -tab / tsb)
//    let zRow = Vec4(x: 0.0, y: 0.0, z: -2.0 / fsn, w: -fan / fsn)
//    let wRow = Vec4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)

    return Mat4([xRow, yRow, zRow, wRow])
//    let xRow = GLKVector4(v: (2.0 / rsl * zoom, 0.0, 0.0, -ral / rsl))
//    let yRow = GLKVector4(v: (0.0, 2.0 / tsb * zoom, 0.0, -tab / tsb))
//    let zRow = GLKVector4(v: (0.0, 0.0, -2.0 / fsn, -fan / fsn))
//    let wRow = GLKVector4(v: (0.0, 0.0, 0.0, 1.0))
//    return GLKMatrix4MakeWithRows(xRow, yRow, zRow, wRow)
  }

  var old: GLKMatrix4 {
    let xRow = GLKVector4(v: (2.0 / rsl * zoom, 0.0, 0.0, -ral / rsl))
    let yRow = GLKVector4(v: (0.0, 2.0 / tsb * zoom, 0.0, -tab / tsb))
    let zRow = GLKVector4(v: (0.0, 0.0, -2.0 / fsn, -fan / fsn))
    let wRow = GLKVector4(v: (0.0, 0.0, 0.0, 1.0))
    return GLKMatrix4MakeWithRows(xRow, yRow, zRow, wRow)
  }

//  var data: [Float] {
//    return cameraMatrix.data + projectionMatrix.data
//  }

//  var dataSize: Int {
//    return data.count * FloatSize
//  }

  private var left: Float = 0.0
  private var right: Float
  private var bottom: Float = 0.0
  private var top: Float
  private var near: Float = -1.0
  private var far: Float = 1.0

  private var ral: Float { return right + left }
  private var rsl: Float { return right - left }
  private var tab: Float { return top + bottom }
  private var tsb: Float { return top - bottom }
  private var fan: Float { return far + near }
  private var fsn: Float { return far - near }

  public var zoom: Float = 1.0
  public var scale: Float {
    didSet {
      zoom = scale
    }
  }

  public override init(size: CGSize) {
    self.scale = 1.0

    self.right = Float(size.width)
    self.top = Float(size.height)

    super.init(size: size)
  }

  func multiplyMatrices(modelViewMatrix: Mat4) -> Mat4 {
    return projectionMatrix * cameraMatrix * modelViewMatrix
  }

  public override func addNode(node: GENode) {
    super.addNode(node)

    node.camera = self
  }
}
