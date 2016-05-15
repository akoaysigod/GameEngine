//
//  Shaders.metal
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
  packed_float4 position;
};

struct InstanceUniforms {
  float4x4 model;
  float4 color;
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut colorVertex(uint vid [[vertex_id]],
                             const device VertexIn* vert [[buffer(0)]],
                             const device InstanceUniforms& instanceUniforms [[buffer(1)]],
                             const device Uniforms& uniforms [[buffer(2)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * instanceUniforms.model * float4(vertIn.position);

  return outVertex;
}

fragment float4 colorFragment(VertexOut interpolated [[stage_in]],
                              constant InstanceUniforms &instanceUniforms [[buffer(0)]]) {
  return instanceUniforms.color;
}
