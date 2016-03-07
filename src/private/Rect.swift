//
//  Rect.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit

typealias Rects = [Rect]

struct Rect {
  static var size: Int {
    return sizeof(vector_float2) + sizeof(vector_float4)
  }
  
  let vertices: Vertices
  let indices: [UInt16]

  init(vertices: Vertices) {
    self.vertices = vertices

    self.indices = [
      0, 1, 2, //upper left triangle
      2, 3, 0  //lower right triangle
    ]
  }

  init(ll: Vertex, ul: Vertex, ur: Vertex, lr: Vertex) {
    self.init(vertices: [ll, ul, ur, lr])
  }

  init(size: CGSize) {
    let width = Float(size.width)
    let height = Float(size.height)

    let ll = Vertex()
    let ul = Vertex(y: height)
    let ur = Vertex(x: width, y: height)
    let lr = Vertex(x: width)

    self.init(vertices: [ll, ul, ur, lr])
  }
}

extension CollectionType where Generator.Element == Rect {
  var vertexData: [Float] {
    return flatMap { $0.vertices.flatMap { $0.data } }
  }

  var vertexSize: Int {
    return FloatSize * vertexData.count
  }

  var indicesData: [UInt16] {
    let unindexed = map { $0.indices }
    let mIndices = (0..<unindexed.count).map { UInt16(4 * $0) } //4 == number vertices

    return zip(mIndices, unindexed).flatMap { index, indices -> [UInt16] in
      indices.map { index + $0 }
    }
  }

  var indicesSize: Int {
    return sizeof(UInt16) * indicesData.count
  }
}
