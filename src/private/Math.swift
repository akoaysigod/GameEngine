//
//  Math.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

final class Math {
  static func degreesToRadians(d: Float) -> Float {
    return (180.0 / Float(M_PI)) * d
  }
}