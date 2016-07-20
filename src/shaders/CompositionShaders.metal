//
//  CompositionShaders.metal
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
#include "Structures.h"

using namespace metal;
using namespace Structures;

struct VertexOutput {
  float4 position [[position]];
};

vertex VertexOutput compositionVertex(uint vid [[vertex_id]],
                                      constant float2 *position [[buffer(0)]])
{
  VertexOutput output;
  output.position = float4(position[vid], 0.0f, 1.0f);
  return output;
}

fragment float4 compositionFragment(VertexOutput interpolated [[stage_in]],
                                    constant float4& ambientColor [[buffer(0)]],
                                    FragOut gBuffer)
{
  return gBuffer.diffuse;
  return float4(gBuffer.diffuse.rgb * gBuffer.light.rgb, gBuffer.diffuse.a);
}
