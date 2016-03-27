//
//  Quad.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit

typealias Quads = [Quad]

struct Quad {
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

  static func rect(width: Float, _ height: Float) -> Quad {
    let ll = Vertex()
    let ul = Vertex(y: height)
    let ur = Vertex(x: width, y: height)
    let lr = Vertex(x: width)

    return Quad(vertices: [ll, ul, ur, lr])
  }

  static func rect(size: CGSize) -> Quad {
    return rect(size.w, size.h)
  }

  static func spriteRect(width: Float, _ height: Float) -> Quad {
    let ll = SpriteVertex(s: 0.0, t: 0.0)
    let ul = SpriteVertex(s: 0.0, t: 1.0, y: height)
    let ur = SpriteVertex(s: 1.0, t: 1.0, x: width, y: height)
    let lr = SpriteVertex(s: 1.0, t: 0.0, x: width)

    return Quad(vertices: [ll, ul, ur, lr])
  }

  static func spriteRect(size: CGSize) -> Quad {
    return spriteRect(size.w, size.h)
  }

  static func spriteRect(width: Int, _ height: Int) -> Quad {
    return spriteRect(Float(width), Float(height))
  }

  static func spriteRect(frame: TextureFrame) -> Quad {
    let x = frame.x
    let y = frame.y
    let sWidth = frame.sWidth
    let sHeight = frame.sHeight
    let tWidth = frame.tWidth
    let tHeight = frame.tHeight

    let ll = SpriteVertex(s: x / tWidth, t: y / tHeight)
    let ul = SpriteVertex(s: x / tWidth, t: (y + sHeight) / tHeight, y: sHeight)
    let ur = SpriteVertex(s: (x + sWidth) / tWidth, t: (y + sHeight) / tHeight, x: sWidth, y: sHeight)
    let lr = SpriteVertex(s: (x + sWidth) / tWidth, t: y / tHeight, x: sWidth)

    return Quad(vertices: [ll, ul, ur, lr])
  }
}

extension CollectionType where Generator.Element == Quad {
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
