//
//  Vertex.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import simd

typealias Vertices = [Vertex]

final class Vertex {
  var x: Float = 0.0
  var y: Float = 0.0
  var z: Float = 0.0
  var w: Float = 1.0

  var color: Color

  var s: Float
  var t: Float

  var data: [Float] {
    return [x, y, z, w, color.red, color.green, color.blue, color.alpha, s, t]
  }

  var dataSize: Int {
    return sizeof(Float) * data.count
  }

  init(x: Float = 0.0, y: Float = 0.0, color: Color) {
    self.x = x
    self.y = y

    self.color = color

    self.s = 0.0
    self.t = 0.0
  }

  // sprite initializer
  init(s: Float, t: Float, x: Float = 0.0, y: Float = 0.0, color: Color) {
    self.s = s
    self.t = t

    self.color = color

    self.x = x
    self.y = y
  }
}
