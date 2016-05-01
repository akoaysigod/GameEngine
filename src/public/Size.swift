//
//  Size.swift
//  GameEngine
//
//  Created by Anthony Green on 5/1/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

/**
 A struct for storing size properties.
 */
public struct Size {
  /// a value representing a width
  public let width: Float
  /// a value representing a height
  public let height: Float

  public init(width: Float, height: Float) {
    self.width = width
    self.height = height
  }

  public init(width: Int, height: Int) {
    self.init(width: Float(width), height: Float(height))
  }
}

extension Size {
  /// Create a size with zero width and height.
  static let zero = Size(width: 0.0, height: 0.0)
}