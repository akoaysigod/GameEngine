//
//  Shaders.metal
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
  packed_float3 position;
  packed_float4 color;
};

struct Uniforms {
  float4x4 mvp;
};

struct VertexOut {
  float4  position [[position]];
  float4  color;
};

vertex VertexOut colorVertex(uint vid [[vertex_id]],
                             const device VertexIn* vert [[buffer(0)]],
                             const device Uniforms& uniforms [[buffer(1)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.mvp * float4(vertIn.position, 1.0);
  outVertex.color    = vertIn.color;

  return outVertex;
}


fragment float4 colorFragment(VertexOut interpolated [[stage_in]]) {
  return interpolated.color;
}