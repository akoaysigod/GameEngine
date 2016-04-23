//
//  Mat4.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import simd

public typealias Mat4 = float4x4
public typealias Vec4 = float4

extension Vec4 {
  init(r: Float, g: Float, b: Float, a: Float) {
    self.init(x: r, y: g, z: b, w: a)
  }

  init(vec3: Vec3, w: Float = 0.0) {
    self.init(x: vec3.x, y: vec3.y, z: vec3.z, w: w)
  }
}

extension Mat4 {
  static var identity: Mat4 {
    return Mat4(1.0)
  }

  var mat3: Mat3 {
    let r1 = Vec3(vec4: self[0])
    let r2 = Vec3(vec4: self[1])
    let r3 = Vec3(vec4: self[2])

    return Mat3([r1, r2, r3])
  }

  var translation: Vec4 {
    return self[3]
  }

  static func scale(x: Float, _ y: Float) -> Mat4 {
    var m = Mat4.identity
    m[0].x = x
    m[1].y = y
    return m
  }

  static func rotate(degrees: Float) -> Mat4 {
    let r = Math.degreesToRadians(degrees)

    let c = cos(r)
    let s = sin(r)

    var m = Mat4.identity

    m[0].x = c
    m[0].y = -s
    m[1].x = s
    m[1].y = c

    return m
  }

  static func rotateAround(axis: Vec4, _ degrees: Float) -> Mat4 {
    var m = Mat4()

    let angle = Math.degreesToRadians(degrees)

    let c = cos(angle)
    let s = sin(angle)

    m[0].x = c + axis.x * axis.x * (1 - c)
    m[0].y = (axis.y * axis.x) * (1 - c) + axis.z * s
    m[0].z = (axis.z * axis.x) - axis.y * s

    m[1].x = (axis.x * axis.y) * (1 - c) - axis.z * s
    m[1].y = c + axis.y * axis.y * (1 - c)
    m[1].z = (axis.z * axis.y) + axis.x * s

    m[2].x = (axis.x * axis.z) * (1 - c) + axis.y * s
    m[2].y = (axis.y * axis.z) * (1 - c) - axis.x * s
    m[2].z = c + axis.z * axis.z * (1 - c)

    m[3].w = 1

    return m
  }

  static func translate(x: Float, _ y: Float, _ z: Float = 0.0) -> Mat4 {
    var m = Mat4.identity

    m[3].x = x
    m[3].y = y
    m[3].z = z

    return m
  }

  static func normalMatrix(m: Mat4, nonUniformScaling: Bool = true) -> Mat3 {
    let upperLeft = m.mat3

    if nonUniformScaling {
      let z = matrix_transpose(matrix_invert(upperLeft.cmatrix))
      return Mat3(z)
    }
    return upperLeft
  }

  static func lookAt(eye: Vec3, center: Vec3, up: Vec3) -> Mat4 {
    /*
     vec4 n = normalize(eye - at);
     vec4 u = normalize(cross(up,n));
     vec4 v = normalize(cross(n,u));
     vec4 t = vec4(0.0, 0.0, 0.0, 1.0);
     mat4 c = mat4(u, v, n, t);
     return c * Translate( -eye );
     */
    let f = normalize(center - eye)
    var u = normalize(up)
    let s = normalize(cross(f, u))
    u = cross(s, f)

    var m = Mat4()

    m[0].x = s.x
    m[0].y = s.y
    m[0].z = s.z

    m[1].x = u.x
    m[1].y = u.y
    m[1].z = u.z

    m[2].x = -f.x
    m[2].y = -f.y
    m[2].z = -f.z

    m[3].x = -dot(s, eye)
    m[3].y = -dot(u, eye)
    m[3].z = dot(f, eye)
    m[3].w = 1.0
    
    return m
  }

  static func perspective(fovy: Float, aspect: Float, near: Float, far: Float) -> Mat4 {
    let top = tan(fovy / 2.0) * near
    let right = top * aspect

    var m = Mat4()

    m[0].x = near / right
    m[1].y = near / top
    m[2].z = -(far + near) / (far - near)
    m[2].w = -1.0
    m[3].z = (-2.0 * far * near) / (far - near)

    return m
  }

  static func orthographic(width: Float, height: Float, zoom: Float = 1.0) -> Mat4 {
    let left: Float = 0.0
    let right = width
    let bottom: Float = 0.0
    let top = height
    let near: Float = -1.0
    let far: Float = 1.0

    let ral = right + left 
    let rsl = right - left 
    let tab = top + bottom 
    let tsb = top - bottom
    let fan = far + near 
    let fsn = far - near

    let xRow = Vec4(x: 2.0 / rsl * zoom, y: 0.0, z: 0.0, w: 0.0)
    let yRow = Vec4(x: 0.0, y: 2.0 / tsb * zoom, z: 0.0, w: 0.0)
    let zRow = Vec4(x: 0.0, y: 0.0, z: -2.0 / fsn, w: 0.0)
    let wRow = Vec4(x: -ral / rsl, y: -tab / tsb, z: -fan / fsn, w: 1.0)

    return Mat4([xRow, yRow, zRow, wRow])
  }

  init(columns: Vec3 ...) {
    assert(columns.count < 4, "Too many columns")

    let c4 = columns.map { Vec4(vec3: $0) }
    self.init(c4)
  }
}

extension Mat4: CustomStringConvertible {
  public var description: String {
    return "\(self[0])\n\(self[1])\n\(self[2])\n\(self[3])\n"
  }
}
