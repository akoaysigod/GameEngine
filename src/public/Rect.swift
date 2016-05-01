//
//  Rect.swift
//  GameEngine
//
//  Created by Anthony Green on 5/1/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

public struct Rect {
  public let x: Float
  public let y: Float
  public var origin: Point {
    return Point(x: x, y: y)
  }
  public let width: Float
  public let height: Float
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
}

extension Rect {
  public static let zero = Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
}
