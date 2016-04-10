//
//  Math.swift
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

    m[1].y = c
    m[1].z = -1 * s

    m[2].y = s
    m[2].z = c

    return m
  }

  static func translate(x: Float, _ y: Float, _ z: Float = 0.0) -> Mat4 {
    var m = Mat4.identity

    m[3].x = x
    m[3].y = y
    m[3].z = z

    return m
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