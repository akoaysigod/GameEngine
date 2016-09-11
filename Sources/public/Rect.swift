//
//  Rect.swift
//  GameEngine
//
//  Created by Anthony Green on 5/1/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

public struct Rect {
  public var x: Float
  public var y: Float

  /// The lower left corner of the Rect.
  public var origin: Point {
    return Point(x: x, y: y)
  }
  public var width: Float
  public var height: Float
  public var size: Size {
    return Size(width: width, height: height)
  }

  public var upperRight: Point {
    return Point(x: x + width, y: y + height)
  }

  public init(x: Float, y: Float, width: Float, height: Float) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }

  public init(x: Int, y: Int, width: Int, height: Int) {
    self.init(x: Float(x), y: Float(y), width: Float(width), height: Float(height))
  }

  public init(origin: Point, size: Size) {
    self.init(x: origin.x, y: origin.y, width: size.width, height: size.height)
  }

  /**
   Determines if two `Rect`s are overlapping.

   The comparison is done like so:
   - left edge of self is greater than comparison right edge
   - right edge of self is less than comparison left edge
   - bottom edge of self is greater than comparison top edge
   - top edge of self is less than comparison bottom edge

   - parameter rect: The rectangle to compare against.

   - returns: True if the rectangles are overlapping, false otherwise.
   */
  public func intersects(_ rect: Rect) -> Bool {
    let toRight = self.x > rect.x + rect.width  
    let toLeft = self.x + width < rect.x        
    let above = self.y > rect.y + rect.height   
    let below = self.y + self.height < rect.y
    return toRight && toLeft && above && below
  }

  /**
   Determines if a point is inside a `Rect`.

   - parameter point: The point to check.

   - returns: True if the point is inside the `Rect`, false otherwise.
   */
  public func containsPoint(_ point: Point) -> Bool {
    let pX = point.x
    let pY = point.y
    return pX > x && pX < upperRight.x && pY > y && pY < upperRight.y
  }
}

extension Rect {
  public static let zero = Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
}
