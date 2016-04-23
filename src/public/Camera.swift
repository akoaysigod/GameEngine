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

public class Camera: Node {
  private var cameraMatrix: Mat4 {
    return Mat4.translate(x, y)
  }

  private var projectionMatrix: Mat4

  public var zoom: Float = 1.0
  public var scale: Float {
    didSet {
      zoom = scale
      projectionMatrix = Mat4.orthographic(right: width, top: height, zoom: zoom)
    }
  }

  private let width: Float
  private let height: Float

  public override init(size: CGSize) {
    self.scale = 1.0

    self.width = Float(size.width)
    self.height = Float(size.height)

    self.projectionMatrix = Mat4.orthographic(right: width, top: height)

    super.init(size: size)
  }

  func multiplyMatrices(modelViewMatrix: Mat4) -> Mat4 {
    return projectionMatrix * cameraMatrix * modelViewMatrix
  }

  public override func addNode(node: Node) {
    super.addNode(node)

    node.camera = self
  }
}
