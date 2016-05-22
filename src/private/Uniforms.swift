//
//  Uniforms.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

struct Uniforms {
  let projection: Mat4
  let view: Mat4
}

struct InstanceUniforms {
  let model: Mat4
}
