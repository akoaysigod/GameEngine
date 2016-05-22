//
//  VertexIn.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

struct VertexIn {
  let position: packed_float4
  let color: packed_float4
  let texCoord: packed_float2
}//I have no idea why I can't get this to work to pass in the vertex data
