//
//  Rect.swift
//  MKTest
//
//  Created by Tony Green on 12/30/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal

class GEColorRect: GENode {
  init(device: MTLDevice, camera: GECamera, size: CGSize, color: UIColor) {
    let vertices = Vertex.rectVertices(size)
    vertices.forEach { (vertex) -> () in
      let fColors = color.rgb
      vertex.r = fColors.r
      vertex.g = fColors.g
      vertex.b = fColors.b
      vertex.a = fColors.a
    }

    super.init(device: device, camera: camera, vertices: vertices, size: size)
  }

  convenience init(device: MTLDevice, camera: GECamera, width: Double, height: Double, color: UIColor) {
    self.init(device: device, camera: camera, size: CGSize(width: width, height: height), color: color)
  }

  override func updateWithDelta(delta: CFTimeInterval) {
    super.updateWithDelta(delta)
  }
}
