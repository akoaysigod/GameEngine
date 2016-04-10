//
//  Mat3.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import simd

public typealias Vec3 = float3
public typealias Mat3 = float3x3

// MARK: size 3 stuff

extension Vec3 {
  init(vec4: Vec4) {
    self.init(x: vec4.x, y: vec4.y, z: vec4.z)
  }
}

extension Mat3 {
  static var identity: Mat3 {
    return Mat3(1.0)
  }
}
