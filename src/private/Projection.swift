//
//  Projection.swift
//  GameEngine
//
//  Created by Anthony Green on 5/22/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

struct Projection {
  fileprivate(set) var projection: Mat4

  init(size: Size) {
    projection = Mat4.orthographic(right: size.width, top: size.height)
  }

  mutating func update(_ size: Size) {
    projection = Mat4.orthographic(right: size.width, top: size.height)
  }
}
