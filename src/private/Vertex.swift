//
//  Vertex.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation

typealias Vertices = [Vertex]

//TODO: add indexes and buffer index stuff
class Vertex {
  var x: Float = 0.0
  var y: Float = 0.0
  var z: Float = 0.0
  var w: Float = 1.0
  
  init(x: Float = 0.0, y: Float = 0.0) {
    self.x = x
    self.y = y
  }

  var data: [Float] {
    return [x, y, z, w, 1.0, 1.0, 1.0, 1.0]
  }

  var dataSize: Int {
    return FloatSize * self.data.count
  }

  class func rectVertices(width: Float, _ height: Float) -> Vertices {
    let lowerLeft = Vertex()
    let lowerRight = Vertex(x: width)
    let upperLeft = Vertex(y: height)
    let upperRight = Vertex(x: width, y: height)

    return [lowerLeft, lowerRight, upperLeft, lowerRight, upperLeft, upperRight]
  }
}

final class SpriteVertex: Vertex {
  var s: Float
  var t: Float

  override var data: [Float] {
    return super.data + [s, t]
  }

  init(s: Float, t: Float, x: Float = 0.0, y: Float = 0.0) {
    self.s = s
    self.t = t

    super.init()

    self.x = x
    self.y = y
  }

  override static func rectVertices(width: Float, _ height: Float) -> Vertices {
    let lowerLeft = SpriteVertex(s: 0.0, t: 0.0)
    let lowerRight = SpriteVertex(s: 1.0, t: 0.0, x: width)
    let upperLeft = SpriteVertex(s: 0.0, t: 1.0, y: height)
    let upperRight = SpriteVertex(s: 1.0, t: 1.0, x: width, y: height)

    return [lowerLeft, lowerRight, upperLeft, lowerRight, upperLeft, upperRight]
  }
}
