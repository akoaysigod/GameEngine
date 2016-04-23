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
  packed_float4 position;
  packed_float2 texCoords;
};

struct TransformedVertex {
  float4 position [[position]];
  float2 texCoords;
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
  float4x4 model;
  float4 color;
};

vertex TransformedVertex textVertex(constant VertexIn *vertices [[buffer(0)]],
                                    constant Uniforms &uniforms [[buffer(1)]],
                                    uint vid [[vertex_id]])
{
  VertexIn vertIn = vertices[vid];
  
  TransformedVertex outVert;
  outVert.position = uniforms.projection * uniforms.view * uniforms.model * float4(vertIn.position);
  outVert.texCoords = vertIn.texCoords;
  
  return outVert;
}

//fragment float4 textFragment(TransformedVertex vert [[stage_in]],
//                            sampler samplr [[sampler(0)]],
//                            texture2d<float, access::sample> texture [[texture(0)]])
//{
//  float4 color = float4(1.0, 1.0, 1.0, 1.0);
//  float edgeDistance = 0.5;
//  float sampleDistance = texture.sample(samplr, vert.texCoords).r;
//  float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
//  float opacity = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
//  
//  return float4(color.r, color.g, color.b, opacity);
//}

fragment float4 textFragment(TransformedVertex vert [[stage_in]],
                             constant Uniforms &uniforms [[buffer(0)]],
                             sampler samplr [[sampler(0)]],
                             texture2d<float, access::sample> texture [[texture(0)]])
{
  float4 color = uniforms.color;
  float edgeDistance = 0.5;
  float dist = texture.sample(samplr, vert.texCoords).r;
  float edgeWidth = 0.75 * length(float2(dfdx(dist), dfdy(dist)));
  float opacity = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, dist);
  
//  float outlineMin = 0.5;
//  float outlineMax = 0.95;
//  if (dist >= outlineMin && dist <= outlineMax) {
//    if (dist <= 0.75) {
//      opacity = smoothstep(outlineMin, 0.75, dist);
//    }
//    else {
//      opacity = smoothstep(0.75, outlineMax, dist);
//    }
//    return mix(color, float4(1.0, 0.0, 0.0, 1.0), opacity);
//  }

  return float4(color.r, color.g, color.b, opacity);
}
