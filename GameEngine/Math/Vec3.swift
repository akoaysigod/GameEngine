//
//  Vec3.swift
//  GameEngine
//
//  Created by Anthony Green on 9/11/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

public typealias Vec3 = float3

public func +(lhs: Vec3, rhs: Vec3) -> Vec3 {
  return Vec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

//public func -(lhs: Vec3, rhs: Vec3) -> Vec3 {
//  return Vec3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
//}

public func *(lhs: Vec3, rhs: Vec3) -> Vec3 {
  return Vec3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
}

public func *(lhs: Float, rhs: Vec3) -> Vec3 {
  return Vec3(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
}

public func /(lhs: Vec3, rhs: Vec3) -> Vec3 {
  return Vec3(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z)
}

public func /(lhs: Vec3, rhs: Float) -> Vec3 {
  return Vec3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
}


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

  public func cross(_ vec: Vec3) -> Vec3 {
    return Vec3(
      self.y * vec.z - self.z * vec.y,
      -(self.x * vec.z - self.z * vec.x),
      self.x * vec.y - self.y * vec.x)
  }

  public static func -(lhs: Vec3, rhs: Vec3) -> Vec3 {
    return Vec3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
  }
}
