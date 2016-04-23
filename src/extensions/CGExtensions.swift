//
//  CGPointExtensions.swift
//  MKTest
//
//  Created by Anthony Green on 1/2/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import UIKit

/// This extension provides conveniences for using `Float`s with `CGPoint`s
extension CGPoint {
  var float: (x: Float, y: Float) {
    return (Float(self.x), Float(self.y))
  }

  /**
   An initializer for creating a `CGPoint` using `Float` values.

   - parameter x: The x value.
   - parameter y: The y value.

   - returns: A new instance of `CGPoint`.
   */
  init(x: Float, y: Float) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
}

/// This extension provides conveniences for using `Float`s with `CGSize`
extension CGSize {
  /// Get the width as a `Float`
  var w: Float {
    return Float(width)
  }
  /// Get the height as a `Float`
  var h: Float {
    return Float(height)
  }

  /**
   Convenience initializer for creating a `CGSize` with `Float` values.

   - parameter width:  The width.
   - parameter height: The height.

   - returns: A new instance of `CGSize`.
   */
  init(width: Float, height: Float) {
    self.init(width: Double(width), height: Double(height))
  }
}
