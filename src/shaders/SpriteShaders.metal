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
  packed_float3 position;
  packed_float4 color;
  packed_float2 texCoord;
};

struct Uniforms {
  float4x4 mvp;
};

struct VertexOut {
  float4  position [[position]];
  float4  color;
  float2 texCoord;
};

vertex VertexOut spriteVertex(uint vid [[vertex_id]],
                                   const device VertexIn* vert [[buffer(0)]],
                                   const device Uniforms& uniforms [[buffer(1)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.mvp * float4(vertIn.position, 1.0);
  outVertex.color    = vertIn.color;
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment float4 spriteFragment(VertexOut interpolated [[stage_in]],
                                   texture2d<float> tex2D [[texture(0)]],
                                   sampler sampler2D [[sampler(0)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  if (color.a < 1.0) {
      discard_fragment();
  }
  return color;
}

//fragment float4 passThroughFragment(VertexOut interpolated [[stage_in]]) {
//    return interpolated.color;
//}
