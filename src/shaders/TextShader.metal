//
//  TextShader.metal
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  packed_float3 position;
  packed_float4 color;
  packed_float2 texCoords;
};

struct TransformedVertex {
  float4 position [[position]];
  float2 texCoords;
};

struct Uniforms {
  float4x4 mvp;
};

vertex TransformedVertex textVertex(constant VertexIn *vertices [[buffer(0)]],
                                    constant Uniforms &uniforms [[buffer(1)]],
                                    uint vid [[vertex_id]])
{
  VertexIn vertIn = vertices[vid];

  TransformedVertex outVert;
  outVert.position = uniforms.mvp * float4(vertIn.position, 1.0);
  outVert.texCoords = vertIn.texCoords;

  return outVert;
}

fragment half4 textFragment(TransformedVertex vert [[stage_in]],
                            sampler samplr [[sampler(0)]],
                            texture2d<float, access::sample> texture [[texture(0)]])
{
  half3 color = half3(1.0, 1.0, 1.0);
  float edgeDistance = 0.5;
  float sampleDistance = texture.sample(samplr, vert.texCoords).r;
  float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
  float opacity = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);

  return half4(color, opacity);
}
