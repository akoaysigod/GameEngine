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
  let color: packed_float4
  let st: packed_float2

  init(x: Float, y: Float, z: Float = 0.0, w: Float = 1.0, s: Float = 0.0, t: Float = 0.0, color: packed_float4) {
    position = [x, y, z, w]
    self.color = color
    st = [s, t]
  }

  init(position: packed_float4, st: packed_float2, color: packed_float4) {
    self.position = position
    self.color = color
    self.st = st
  }
}

typealias Quads = [Quad]

struct Quad {
  let vertices: Vertices
  let size: Int

  static let size = 4 * MemoryLayout<Vertex>.stride

  init(vertices: Vertices) {
    self.vertices = vertices
    size = vertices.count * MemoryLayout<Vertex>.stride
  }

  static func rect(width: Float, height: Float, color: Color) -> Quad {
    let ll = Vertex(x: 0, y: 0, color: color.vec4)
    let ul = Vertex(x: 0, y: height, color: color.vec4)
    let ur = Vertex(x: width, y: height, color: color.vec4)
    let lr = Vertex(x: width, y: 0, color: color.vec4)

    return Quad(vertices: [ul, ll, lr, ur])
  }

  static func rect(size: Size, color: Color) -> Quad {
    return rect(width: size.width, height: size.height, color: color)
  }

  static func spriteRect(frame: TextureFrame, color: Color) -> Quad {
    let sWidth = frame.sWidth
    let sHeight = frame.sHeight
    let tWidth = frame.tWidth
    let tHeight = frame.tHeight

    let halfWidth = 0.5 / tWidth
    let halfHeight = 0.5 / tHeight

    //hmm this was just guess work and might break in the future
    let x = frame.x + halfWidth
    let y = frame.y - halfHeight

    let ll = Vertex(x: 0, y: sHeight, s: x / tWidth, t: (y + sHeight) / tHeight, color: color.vec4)
    let ul = Vertex(x: 0, y: 0, s: x / tWidth, t: y / tHeight, color: color.vec4)
    let ur = Vertex(x: sWidth, y: 0, s: (x + sWidth) / tWidth, t: y / tHeight, color: color.vec4)
    let lr = Vertex(x: sWidth, y: sHeight, s: (x + sWidth) / tWidth, t: (y + sHeight) / tHeight, color: color.vec4)

    return Quad(vertices: [ll, ul, ur, lr])
  }
}

extension Quad {
  //this is upside down? I ran into this problem before and now it's upside down again, i don't know anymore
  private static var indicesData: [UInt16] {
    //this is clockwise but the textures end up being anticlockwise so ff == anti 
    //which is why the Quad for ShapeNode is different from the sprite one
    return [
      0, 1, 2, //upper left triangle
      2, 3, 0  //lower right triangle
    ]
  }

  static func indices(_ length: Int) -> (data: [UInt16], size: Int) {
    let r = repeatElement(Quad.indicesData, count: length)
    let i = r.enumerated().map { (i, e) in
      e.map {
        UInt16(i * 4) + $0
      }
    }.joined()
    return (Array(i), i.count * MemoryLayout<UInt16>.size)
  }

  static var indicesSize: Int { return MemoryLayout<UInt16>.size * indicesData.count }
}
