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
  packed_float4 position [[attribute(0)]];
  packed_float4 color    [[attribute(2)]];
  packed_float2 texCoord [[attribute(1)]];
  packed_float2 pad;
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
  float2 texCoord;
};

vertex VertexOut spriteVertex(ushort vid [[vertex_id]],
                              const device VertexIn* vert [[buffer(0)]],
                              constant Uniforms& uniforms [[buffer(2)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  outVertex.color = vertIn.color;
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment float4 spriteFragment(VertexOut interpolated [[stage_in]],
                               texture2d<float> tex2D [[texture(0)]],
                               sampler sampler2D [[sampler(0)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  return color * interpolated.color;
}
