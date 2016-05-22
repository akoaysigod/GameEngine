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
    return sizeof(vector_float2) + (2 * sizeof(vector_float4))
  }
  
  let vertices: Vertices

  init(vertices: Vertices) {
    self.vertices = vertices
  }

  init(ll: Vertex, ul: Vertex, ur: Vertex, lr: Vertex) {
    self.init(vertices: [ll, ul, ur, lr])
  }

  static func rect(width: Float, _ height: Float, color: Color) -> Quad {
    let ll = Vertex(color: color)
    let ul = Vertex(y: height, color: color)
    let ur = Vertex(x: width, y: height, color: color)
    let lr = Vertex(x: width, color: color)

    return Quad(vertices: [ul, ll, lr, ur])
  }

  static func rect(size: Size, color: Color) -> Quad {
    return rect(size.width, size.height, color: color)
  }

  static func spriteRect(width: Float, _ height: Float, color: Color) -> Quad {
    let ll = Vertex(s: 0.0, t: 0.0, color: color)
    let ul = Vertex(s: 0.0, t: 1.0, y: height, color: color)
    let ur = Vertex(s: 1.0, t: 1.0, x: width, y: height, color: color)
    let lr = Vertex(s: 1.0, t: 0.0, x: width, color: color)

    return Quad(vertices: [ll, ul, ur, lr])
  }

  static func spriteRect(size: Size, color: Color) -> Quad {
    return spriteRect(size.width, size.height, color: color)
  }

  static func spriteRect(width: Int, _ height: Int, color: Color) -> Quad {
    return spriteRect(Float(width), Float(height), color: color)
  }

  static func spriteRect(frame: TextureFrame, color: Color) -> Quad {
    let x = frame.x
    let y = frame.y
    let sWidth = frame.sWidth
    let sHeight = frame.sHeight
    let tWidth = frame.tWidth
    let tHeight = frame.tHeight

    let ll = Vertex(s: (x + sWidth) / tWidth, t: (y + sHeight) / tHeight, x: sWidth, color: color)
    let ul = Vertex(s: (x + sWidth) / tWidth, t: y / tHeight, x: sWidth, y: sHeight, color: color)
    let ur = Vertex(s: x / tWidth, t: y / tHeight, y: sHeight, color: color)
    let lr = Vertex(s: x / tWidth, t: (y + sHeight) / tHeight, color: color)

    return Quad(vertices: [ll, ul, ur, lr])
  }
}

extension Quad {
  static var indicesData: [UInt16] {
    return [
      0, 1, 2, //upper left triangle
      2, 3, 0  //lower right triangle
    ]
  }

  static var indicesSize: Int { return sizeof(UInt16) * indicesData.count }
}

extension CollectionType where Generator.Element == Quad {
  var vertexData: [Float] {
    return flatMap { $0.vertices.flatMap { $0.data } }
  }

  var vertexSize: Int {
    return sizeof(Float) * vertexData.count
  }
}
