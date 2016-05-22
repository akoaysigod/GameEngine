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

  var s: Float
  var t: Float

  var data: [Float] {
    return [x, y, z, w, s, t]
  }

  var dataSize: Int {
    return sizeof(Float) * data.count
  }

  static var dataSize: Int {
    return (2 * sizeof(packed_float4)) + sizeof(packed_float2)
  }

  init(x: Float = 0.0, y: Float = 0.0) {
    self.x = x
    self.y = y

    self.s = 0.0
    self.t = 0.0
  }

  // sprite initializer
  init(s: Float, t: Float, x: Float = 0.0, y: Float = 0.0) {
    self.s = s
    self.t = t

    self.x = x
    self.y = y
  }
}
