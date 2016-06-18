//
//  BumpShader.metal
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//https://en.wikipedia.org/wiki/Sobel_operator
//constant float dXSobel[] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
//constant float dYSobel[] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};

static half avg(texture2d<half, access::sample> sTex, sampler samp, float2 st) {
  half4 c = sTex.sample(samp, st);
  //half avg = (c.r * 0.21) + (c.g * 0.72) + (c.b * 0.07);
  return (c.r + c.g + c.b) / 3.0;
}

kernel void bump(texture2d<half, access::sample> sTex [[texture(0)]],
                 texture2d<half, access::write> dTex [[texture(1)]],
                 sampler samp [[sampler(0)]],
                 uint2 gridPos [[thread_position_in_grid]]) {

  half ul = avg(sTex, samp, float2(gridPos.x - 1, gridPos.y + 1));
  half u = avg(sTex, samp, float2(gridPos.x, gridPos.y + 1));
  half ur = avg(sTex, samp, float2(gridPos.x + 1, gridPos.y + 1));

  half l = avg(sTex, samp, float2(gridPos.x - 1, gridPos.y));
  half r = avg(sTex, samp, float2(gridPos.x + 1, gridPos.y));

  half dl = avg(sTex, samp, float2(gridPos.x - 1, gridPos.y -1));
  half d = avg(sTex, samp, float2(gridPos.x, gridPos.y - 1));
  half dr = avg(sTex, samp, float2(gridPos.x + 1, gridPos.y - 1));

  half red = ((ur + 2 * r + dr) - (ul + l + dl)) * 0.5 + 0.5;
  half green = ((dl + 2 * d + dr) - (ul + 2 * u + ur)) * 0.5 + 0.5;
  half a = sTex.sample(samp, float2(gridPos)).a;

  dTex.write(half4(red, green, 0.7, a), gridPos);
}
