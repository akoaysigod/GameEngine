//
//  Shaders.metal
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
  packed_float4 position;
  packed_float2 texCoord;
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
  float4x4 model;
  float4 color;
};

struct VertexOut {
  float4 position [[position]];
  float2 texCoord;
};

vertex VertexOut spriteVertex(uint vid [[vertex_id]],
                              const device VertexIn* vert [[buffer(0)]],
                              const device Uniforms& uniforms [[buffer(1)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * uniforms.model * float4(vertIn.position);
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment float4 spriteFragment(VertexOut interpolated [[stage_in]],
                               constant Uniforms &uniforms [[buffer(0)]],
                               texture2d<float> tex2D [[texture(0)]],
                               sampler sampler2D [[sampler(0)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  return color * uniforms.color;
}

//fragment float4 passThroughFragment(VertexOut interpolated [[stage_in]]) {
//    return interpolated.color;
//}
