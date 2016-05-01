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
  public var origin: Point {
    return Point(x: x, y: y)
  }
  public var width: Float
  public var height: Float
  public var size: Size {
    return Size(width: width, height: height)
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
  public func intersects(rect: Rect) -> Bool {
    let toRight = self.x > rect.x + rect.width  
    let toLeft = self.x + width < rect.x        
    let above = self.y > rect.y + rect.height   
    let below = self.y + self.height < rect.y
    return toRight && toLeft && above && below
  }
}

extension Rect {
  public static let zero = Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
}
