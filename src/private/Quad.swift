//
//  Quad.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

typealias Quads = [Quad]

struct Quad {
  static var size: Int {
    return sizeof(packed_float2) + sizeof(packed_float4)
    return 4 * sizeof(vector_float4)
  }
  
  let data: [Float]
  let size: Int

  init(vertices: Vertices) {
    data = vertices.flatMap { $0.data }
    size = sizeof(Float) * data.count
  }

  init(ll: Vertex, ul: Vertex, ur: Vertex, lr: Vertex) {
    self.init(vertices: [ll, ul, ur, lr])
  }

  static func rect(width: Float, _ height: Float) -> Quad {
    let ll = Vertex()
    let ul = Vertex(y: height)
    let ur = Vertex(x: width, y: height)
    let lr = Vertex(x: width)

    return Quad(vertices: [ul, ll, lr, ur])
  }

  static func rect(size: Size) -> Quad {
    return rect(size.width, size.height)
  }

  static func spriteRect(width: Float, _ height: Float) -> Quad {
    let ll = Vertex(s: 0.0, t: 0.0)
    let ul = Vertex(s: 0.0, t: 1.0, y: height)
    let ur = Vertex(s: 1.0, t: 1.0, x: width, y: height)
    let lr = Vertex(s: 1.0, t: 0.0, x: width)

    return Quad(vertices: [ll, ul, ur, lr])
  }

  static func spriteRect(size: Size) -> Quad {
    return spriteRect(size.width, size.height)
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

    let ll = Vertex(s: (x + sWidth) / tWidth, t: (y + sHeight) / tHeight, x: sWidth)
    let ul = Vertex(s: (x + sWidth) / tWidth, t: y / tHeight, x: sWidth, y: sHeight)
    let ur = Vertex(s: x / tWidth, t: y / tHeight, y: sHeight)
    let lr = Vertex(s: x / tWidth, t: (y + sHeight) / tHeight)

    return Quad(vertices: [ll, ul, ur, lr])
  }
}

extension Quad {
  static var indicesData: [UInt16] {
    //this is clockwise but the textures end up being anticlockwise so ff == anti 
    //which is why the Quad for ShapeNode is different from the sprite one
    return [
      0, 1, 2, //upper left triangle
      2, 3, 0  //lower right triangle
    ]
  }

  static var indicesSize: Int { return sizeof(UInt16) * indicesData.count }
}

extension CollectionType where Generator.Element == Quad {
  var vertexData: [Float] {
    return flatMap { $0.data }
  }

  var vertexSize: Int {
    return sizeof(Float) * vertexData.count
  }
}
