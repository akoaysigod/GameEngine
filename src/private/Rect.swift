//
//  Rect.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

typealias Rects = [Rect]

struct Rect {
  let vertices: Vertices
  let indices: [UInt16]

  init(vertices: Vertices) {
    self.vertices = vertices

    self.indices = [
      0, 1, 2, //upper left triangle
      0, 3, 2  //lower right triangle
    ]
  }

  init(ll: Vertex, ul: Vertex, ur: Vertex, lr: Vertex) {
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
    return flatMap { $0.indices }
  }

  var indicesSize: Int {
    return sizeof(UInt16) * indicesData.count
  }
}
