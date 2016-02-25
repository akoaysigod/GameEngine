//
//  Vertex.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import GLKit

typealias Vertices = [Vertex]

class Vertex {
  var x: Float = 0.0
  var y: Float = 0.0
  var z: Float = 0.0
  var r: Float = 1.0
  var g: Float = 1.0
  var b: Float = 1.0
  var a: Float = 1.0

  init(x: Float, y: Float, r: Float, g: Float, b: Float) {
    self.x = x
    self.y = y
    self.r = r
    self.g = g
    self.b = b
  }

  init(x: Float = 0.0, y: Float = 0.0) {
    self.x = x
    self.y = y
  }


  var data: [Float] {
    return [x, y, z, r, g, b, a]
  }

  var dataSize: Int {
    return FloatSize * self.data.count
  }

  class func rectVertices(size: CGSize) -> Vertices {
    let width = Float(size.width)
    let height = Float(size.height)

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

  override static func rectVertices(size: CGSize) -> Vertices {
    let width = Float(size.width)
    let height = Float(size.height)

    let lowerLeft = SpriteVertex(s: 0.0, t: 0.0)
    let lowerRight = SpriteVertex(s: 1.0, t: 0.0, x: width)
    let upperLeft = SpriteVertex(s: 0.0, t: 1.0, y: height)
    let upperRight = SpriteVertex(s: 1.0, t: 1.0, x: width, y: height)

    return [lowerLeft, lowerRight, upperLeft, lowerRight, upperLeft, upperRight]
  }
}
