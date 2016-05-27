//
//  Quad.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

typealias Vertices = [Vertex]

struct Vertex {
  let position: packed_float4
  let st: packed_float2

  init(x: Float, y: Float, z: Float = 0.0, w: Float = 1.0, s: Float = 0.0, t: Float = 0.0) {
    position = [x, y, z, w]
    st = [s, t]
  }
}

typealias Quads = [Quad]

struct Quad {
//  static var size: Int {
//    return sizeof(packed_float2) + sizeof(packed_float4)
//    return 4 * sizeof(vector_float4)
//  }

  let vertices: Vertices
  let size: Int

  init(vertices: Vertices) {
    self.vertices = vertices
    size = vertices.count * strideof(Vertex)
  }

  static func rect(width: Float, _ height: Float) -> Quad {
    let st: packed_float2 = [0, 0]

    let ll = Vertex(x: 0, y: 0)
    let ul = Vertex(x: 0, y: height)
    let ur = Vertex(x: width, y: height)
    let lr = Vertex(x: width, y: 0)

    return Quad(vertices: [ul, ll, lr, ur])
  }

  static func rect(size: Size) -> Quad {
    return rect(size.width, size.height)
  }

//  static func spriteRect(width: Float, _ height: Float) -> Quad {
//    let ll = Vertex(s: 0.0, t: 0.0)
//    let ul = Vertex(s: 0.0, t: 1.0, y: height)
//    let ur = Vertex(s: 1.0, t: 1.0, x: width, y: height)
//    let lr = Vertex(s: 1.0, t: 0.0, x: width)

//    return Quad(vertices: [ll, ul, ur, lr])
//  }

//  static func spriteRect(size: Size) -> Quad {
//    return spriteRect(size.width, size.height)
//  }
//
//  static func spriteRect(width: Int, _ height: Int) -> Quad {
//    return spriteRect(Float(width), Float(height))
//  }

  static func spriteRect(frame: TextureFrame) -> Quad {
    let x = frame.x
    let y = frame.y
    let sWidth = frame.sWidth
    let sHeight = frame.sHeight
    let tWidth = frame.tWidth
    let tHeight = frame.tHeight

    //let ll = Vertex(position: [sWidth, 0, 0, 1], st: [(x + sWidth) / tWidth, (y + sHeight) / tHeight])
    let ll = Vertex(x: sWidth, y: 0, s: (x + sWidth) / tWidth, t: (y + sHeight) / tHeight)
    //let ul = Vertex(position: [sWidth, sHeight, 0, 1], st: [(x + sWidth) / tWidth, y / tHeight])
    let ul = Vertex(x: sWidth, y: sHeight, s: (x + sWidth) / tWidth, t: y / tHeight)
    //let ur = Vertex(position: [0, sHeight, 0, 1], st: [x / tWidth, y / tHeight])
    let ur = Vertex(x: 0, y: sHeight, s: x / tWidth, t: y / tHeight)
    //let lr = Vertex(position: [0, 0, 0, 1], st: [x / tWidth, (y + sHeight) / tHeight])
    let lr = Vertex(x: 0, y: 0, s: x / tWidth, t: (y + sHeight) / tHeight)

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
