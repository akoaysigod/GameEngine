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
  packed_float4 position [[attribute(0)]];
  packed_float2 texCoord [[attribute(1)]]; //just makes it a bit easier to program this, it's not really being used
  packed_float4 color    [[attribute(2)]];
  packed_float2 pad;
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
  float4 color;
};

vertex VertexOut colorVertex(ushort vid [[vertex_id]],
                             ushort iid [[instance_id]],
                             const device VertexIn* vert [[buffer(0)]],
                             const device InstanceUniforms* instanceUniforms [[buffer(1)]],
                             const device Uniforms& uniforms [[buffer(2)]])
{
  VertexIn vertIn = vert[vid];
  InstanceUniforms instanceIn = instanceUniforms[iid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * instanceIn.model * float4(vertIn.position);
  outVertex.color = instanceIn.color;

  return outVertex;
}

fragment float4 colorFragment(VertexOut interpolated [[stage_in]]) {
  return interpolated.color;
}
