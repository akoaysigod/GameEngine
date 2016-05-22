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
  packed_float4 position [[attribute(0)]];
  packed_float2 texCoord [[attribute(2)]];
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
  float2 texCoords;
};

vertex VertexOut textVertex(uint vid [[vertex_id]],
                            const device VertexIn *vertices [[buffer(0)]],
                            const device InstanceUniforms &instanceUniforms [[buffer(1)]],
                            const device Uniforms &uniforms [[buffer(2)]])
{
  VertexIn vertIn = vertices[vid];
  
  VertexOut outVert;
  outVert.position = uniforms.projection * uniforms.view * instanceUniforms.model * float4(vertIn.position);
  outVert.color = instanceUniforms.color;
  outVert.texCoords = vertIn.texCoord;
  
  return outVert;
}

//fragment float4 textFragment(VertexOut vert [[stage_in]],
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

fragment float4 textFragment(VertexOut vert [[stage_in]],
                             sampler samplr [[sampler(0)]],
                             texture2d<float, access::sample> texture [[texture(0)]])
{
  float4 color = vert.color;
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
