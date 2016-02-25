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

class GEColorRect: GERenderNode {
  init(size: CGSize, color: UIColor) {
    let vertices = Vertex.rectVertices(size)
    vertices.forEach { (vertex) -> () in
      let fColors = color.rgb
      vertex.r = fColors.r
      vertex.g = fColors.g
      vertex.b = fColors.b
      vertex.a = fColors.a
    }
    
    super.init(vertices: vertices)
    
    self.size = size
  }

  convenience init(width: Double, height: Double, color: UIColor) {
    self.init(size: CGSize(width: width, height: height), color: color)
  }
}
