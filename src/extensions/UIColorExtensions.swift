//
//  UIColorExtensions.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import MetalKit
import simd
import UIKit

public typealias GEColor = (r: Float, g: Float, b: Float, a: Float)

/**
 Some extensions to make UIColor easier to use with Metal. I might axe UIColor at some point and create my own replacement.
 */
public extension UIColor {
  /// Creates a vec4 from the UIColor to be passed to shaders.
  var vec4: Vec4 {
    return Vec4(r: rgb.r, g: rgb.g, b: rgb.b, a: rgb.a)
  }

  /// Get the float values for each component.
  var rgb: (r: Float, g: Float, b: Float, a: Float) {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return (Float(red), Float(green), Float(blue), Float(alpha))
    }
    return (1.0, 1.0, 1.0, 1.0) //just return white on error
  }

  /// This is used to turn a UIColor into a MTLClearColor to be used in an MTLRenderPassDescriptor
  var clearColor: MTLClearColor {
    let color = rgb
    return MTLClearColor(red: Double(color.r), green: Double(color.g), blue: Double(color.b), alpha: Double(color.a))
  }
}
