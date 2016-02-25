//
//  TextShader.metal
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Tony Green. All rights reserved.
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
  //  float4x4 viewProjectionMatrix;
  //  float4 foregroundColor;
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
                            constant Uniforms &uniforms [[buffer(0)]],
                            sampler samplr [[sampler(0)]],
                            texture2d<float, access::sample> texture [[texture(0)]])
{
  float4 color = float4(1.0, 1.0, 1.0, 1.0); //uniforms.foregroundColor;
  // Outline of glyph is the isocontour with value 50%
  float edgeDistance = 0.5;
  // Sample the signed-distance field to find distance from this fragment to the glyph outline
  float sampleDistance = texture.sample(samplr, vert.texCoords).r;
  // Use local automatic gradients to find anti-aliased anisotropic edge width, cf. Gustavson 2012
  float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
  // Smooth the glyph edge by interpolating across the boundary in a band with the width determined above
  float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
  
  return half4(color.r, color.g, color.b, insideness);
}
