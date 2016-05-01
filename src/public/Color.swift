//
//  Color.swift
//  GameEngine
//
//  Created by Anthony Green on 4/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

public struct Color {
  public var red: Float
  public var green: Float
  public var blue: Float
  public var alpha: Float = 1.0

  var clearColor: MTLClearColor {
    return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
  }

  var vec4: Vec4 {
    return Vec4(r: red, g: green, b: blue, a: alpha)
  }

  public init(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float = 1.0) {
    assert(red <= 1.0 && green <= 1.0 && blue <= 1.0 && alpha <= 1.0, "Color components should be less than 1.0.")
    assert(red >= 0.0 && green >= 0.0 && blue >= 0.0 && alpha >= 0.0, "Color components should be greater than 0.0.")

    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }
}

extension Color {
  public static let white = Color(1.0, 1.0, 1.0)
  public static let lightGray = Color(0.75, 0.75, 0.75)
  public static let gray = Color(0.5, 0.5, 0.5)
  public static let darkGray = Color(0.25, 0.25, 0.25)
  public static let black = Color(0.0, 0.0, 0.0)
  public static let red = Color(1.0, 0.0, 0.0)
  public static let green = Color(0.0, 1.0, 0.0)
  public static let blue = Color(0.0, 0.0, 1.0)
  public static let cyan = Color(0.0, 1.0, 1.0)
  public static let yellow = Color(1.0, 1.0, 0.0)
  public static let magenta = Color(1.0, 0.0, 1.0)
  public static let orange = Color(1.0, 0.5, 0.0)
  public static let purple = Color(0.0, 0.5, 0.5)
  public static let brown = Color(0.6, 0.4, 0.2)
  public static let clear = Color(0.0, 0.0, 0.0, 0.0)
}
