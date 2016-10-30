//
//  Vec4.swift
//  GameEngine
//
//  Created by Anthony Green on 9/11/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

public typealias Vec4 = float4
public typealias PVec4 = packed_float4

/// Vec4 is a typealias for simd's float4, this extension provides convenience methods for initializing.
public extension Vec4 {
  /**
   A convenience initializer so you know it's being used as a color vector.

   - note: All values should be 0.0 <= value <= 1.0

   - parameter r: The red amount.
   - parameter g: The green amount.
   - parameter b: The blue amount.
   - parameter a: The alpha amount.

   - returns: A new `Vec4` representing a color.
   */
  public init(r: Float, g: Float, b: Float, a: Float) {
    self.init(x: r, y: g, z: b, w: a)
  }

  /**
   Given a `Vec3` and a w component create a `Vec4`

   - parameter vec3: The vector to use for the first 3 components.
   - parameter w:    The w component.

   - returns: a new `Vec4`.
   */
  public init(vec3: Vec3, w: Float = 0.0) {
    self.init(x: vec3.x, y: vec3.y, z: vec3.z, w: w)
  }
}
