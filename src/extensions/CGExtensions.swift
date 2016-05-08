//
//  CGPointExtensions.swift
//  MKTest
//
//  Created by Anthony Green on 1/2/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import UIKit

/// This extension provides conveniences for using `Float`s with `CGPoint`s
public extension CGPoint {
  public var float: (x: Float, y: Float) {
    return (Float(self.x), Float(self.y))
  }

  public var point: Point {
    return Point(x: float.x, y: float.y)
  }

  /**
   An initializer for creating a `CGPoint` using `Float` values.

   - parameter x: The x value.
   - parameter y: The y value.

   - returns: A new instance of `CGPoint`.
   */
  public init(x: Float, y: Float) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
}

/// This extension provides conveniences for using `Float`s with `CGSize`
public extension CGSize {
  /// Get the width as a `Float`
  public var w: Float {
    return Float(width)
  }
  /// Get the height as a `Float`
  public var h: Float {
    return Float(height)
  }

  public var size: Size {
    return Size(width: w, height: h)
  }

  /**
   Convenience initializer for creating a `CGSize` with `Float` values.

   - parameter width:  The width.
   - parameter height: The height.

   - returns: A new instance of `CGSize`.
   */
  public init(width: Float, height: Float) {
    self.init(width: Double(width), height: Double(height))
  }
}
