//
//  Math.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

infix operator ** {}

public func **(lhs: Float, rhs: Int) -> Float {
  return pow(lhs, rhs)
}

/// A collection of Math related helper functions.
public final class Math {
  /**
   Convert degrees to radians.

   - parameter d: The degrees to be converted.

   - returns: The equivalent radians.
   */
  public static func degreesToRadians(d: Float) -> Float {
    return (Float(M_PI) / 180.0) * d
  }
}