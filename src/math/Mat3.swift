//
//  Mat3.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import simd

public typealias Vec3 = float3
public typealias Mat3 = float3x3

/**
 Vec3 is a typealias for simd's float3
 
 This extension provides convenience initializers.
 */
public extension Vec3 {
  /**
   Create a `Vec3` using the first 3 components of a `Vec4`.

   - parameter vec4: The vector to be used for the first 3 components.

   - returns: A new `Vec3`.
   */
  public init(vec4: Vec4) {
    self.init(x: vec4.x, y: vec4.y, z: vec4.z)
  }
}

/**
 Mat3 is a typealias for simd's float3x3
 
 This extension just creates an identity matrix right now.
 */
public extension Mat3 {
  /// Create an identity matrix
  public static var identity: Mat3 {
    return Mat3(1.0)
  }
}
