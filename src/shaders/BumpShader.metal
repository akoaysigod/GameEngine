//
//  BumpShader.metal
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void bump(texture2d<half, access::sample> sTex [[texture(0)]],
                 texture2d<half, access::write> dTex [[texture(1)]],
                 sampler samp [[sampler(0)]],
                 uint2 gridPos [[thread_position_in_grid]]) {
  float2 st = float2(float(gridPos.x) / sTex.get_width(),
                     float(gridPos.y) / sTex.get_height());

  half4 sColor = sTex.sample(samp, st);

  half avg = step((sColor.r + sColor.g + sColor.b) / 3.0, 0.5);
  half4 color = half4(avg, avg, avg, sColor.a);
  dTex.write(color, gridPos);
}
