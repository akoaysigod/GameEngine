//
//  Composition.metal
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
#include "Structures.h"

using namespace metal;

struct VertexOutput
{
  float4 position [[position]];
};

vertex VertexOutput compositionVertex(constant float2 *posData [[buffer(0)]],
                                      uint vid [[vertex_id]])
{
  VertexOutput output;
  output.position = float4(posData[vid], 0.0f, 1.0f);
  return output;
}

fragment half4 compositionFragment(VertexOutput interpolated [[stage_in]]) {
  return half4(1, 1, 1, 1);
}