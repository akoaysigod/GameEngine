//
//  Camera.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import simd
import UIKit

public class CameraNode: Node {
  var view: Mat4 {
    return Mat4.translate(x, y) * Mat4.scale(zoom, zoom)
  }

  let projection: Mat4

  public var zoom: Float = 1.0
  public var scale: Float {
    didSet {
      zoom = scale
    }
  }

  private let width: Float
  private let height: Float

  public override init(size: Size) {
    self.scale = 1.0

    self.width = Float(size.width)
    self.height = Float(size.height)

    self.projection = Mat4.orthographic(right: width, top: height)

    super.init(size: size)
  }

//  func multiplyMatrices(modelViewMatrix: Mat4) -> Mat4 {
//    return projectionMatrix * cameraMatrix * modelViewMatrix
//  }

  public override func addNode(node: Node) {
    super.addNode(node)

    node.camera = self
  }
}
