//
//  Point.swift
//  GameEngine
//
//  Created by Anthony Green on 5/1/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

public struct Point {
  public let x: Float
  public let y: Float

  public init(x: Float, y: Float) {
    self.x = x
    self.y = y
  }

  public init(x: Int, y: Int) {
    self.init(x: Float(x), y: Float(y))
  }
}

extension Point {
  /// Create a point with 0.0 for both elements
  public static let zero = Point(x: 0.0, y: 0.0)
}
