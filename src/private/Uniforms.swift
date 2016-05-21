//
//  Uniforms.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

struct Uniforms {
  var projection: Mat4
  var view: Mat4
}

struct InstanceUniforms {
  var model: Mat4
  var color: Vec4
}

struct SInstanceUniforms {
  var model: Mat4
  var color: Vec4
  var texCoords: packed_float2
}
