//
//  LightShaders.metal
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
#include "Structures.h"

using namespace metal;
using namespace Structures;

//struct VertexIn {
//  float4 position [[attribute(0)]];
//};

struct VertexIn {
  packed_float4 position [[attribute(0)]];
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
};

struct VertexOut {
  float4 position [[position]];
  float4 pos;
};

struct LightUniforms {
  float2 resolution;
};

struct LightData {
  float4 position;
  float4 color;
};

vertex VertexOut lightVertex(ushort vid [[vertex_id]],
                             const device VertexIn* vert [[buffer(0)]],
                             constant float2& position [[buffer(1)]],
                             constant Uniforms& uniforms [[buffer(2)]]) {
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  outVertex.pos = uniforms.projection * float4(position, 0.0, 1.0);

  return outVertex;
}

fragment FragOut lightFragment(VertexOut interpolated [[stage_in]],
                                  constant LightUniforms& lightUniforms [[buffer(0)]],
                                  constant LightData& lights [[buffer(1)]],
                                  FragOut gBuffer)
{
  float4 normal = gBuffer.normal;

  float2 resolution = lightUniforms.resolution;

  float3 n = normalize(normal.xyz * 2.0 - 1.0);

  LightData lightData = lights;

  float2 posxy = float2(interpolated.pos.x / resolution.x, interpolated.pos.y / resolution.y);
  float3 lightDir = float3(posxy - (interpolated.position.xy / resolution), lightData.position.z);
  lightDir.x *= resolution.x / resolution.y;
  //lightDir.x /= (1000.0 / resolution.x);
  //lightDir.y /= (1000.0 / resolution.y);

  float3 l = normalize(lightDir);

  float3 diffuse = lightData.color.xyz * max(dot(n, l), 0.0);

  float d = length(lightDir);
  //float attenuation = 1.0 / (0.4 + (3.0 * d) + (20.0 * d * d));
  float attenuation = (1.0 / (4.0 * d));

  float4 light = gBuffer.light;
  light.rgb += diffuse * attenuation;

  FragOut fragOut = FragOut();
  fragOut.diffuse = gBuffer.diffuse;
  fragOut.normal = gBuffer.normal;
  fragOut.light = light;

  return fragOut;
}
