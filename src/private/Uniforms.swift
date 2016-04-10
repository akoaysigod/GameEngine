//
//  Uniforms.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import simd
import UIKit

struct Uniforms {
  var mvp: Mat4
  var color: Vec4

  init(mvp: Mat4, color: UIColor) {
    self.mvp = mvp
    self.color = color.vec4
  }
}
