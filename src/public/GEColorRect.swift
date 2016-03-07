//
//  Rect.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal

class GEColorRect: GENode, Renderable {
  var vertices: Vertices
  var rects: Rects!
  var texture: MTLTexture? = nil
  var vertexBuffer: MTLBuffer!
  var sharedUniformBuffer: MTLBuffer!
  var indexBuffer: MTLBuffer!
  var uniformBufferQueue: BufferQueue!

  init(size: CGSize, color: UIColor) {
    let vertices = Vertex.rectVertices(size)
    vertices.forEach { (vertex) -> () in
      //let fColors = color.rgb
    }

    self.vertices = vertices

    super.init()

    self.size = size

    self.rects = [Rect(size: size)]
  }

  convenience init(width: Double, height: Double, color: UIColor) {
    self.init(size: CGSize(width: width, height: height), color: color)
  }
}
