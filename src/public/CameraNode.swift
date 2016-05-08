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
    //return Mat4.translate(x, y) * Mat4.scale(zoom, zoom)
    return Mat4.translate(x + (width * anchorPoint.x), y + (height * anchorPoint.y)) * Mat4.scale(zoom, zoom)
  }

  let projection: Mat4

  public var zoom: Float = 1.0
  public var scale: Float = 1.0 {
    didSet {
      zoom = scale
    }
  }

  private let width: Float
  private let height: Float

  public override init(size: Size) {
    width = Float(size.width)
    height = Float(size.height)

    projection = Mat4.orthographic(right: width, top: height)

    super.init(size: size)

    anchorPoint = Point(x: 0.5, y: 0.5)
  }

  public override func addNode(node: Node) {
    super.addNode(node)

    node.camera = self
  }
}
