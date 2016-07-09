//
//  Shaders.metal
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

#include <metal_stdlib>
#include "Structures.h"

using namespace metal;
using namespace Structures;

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

struct LightUniforms {
  float3 ambientColor;
  float2 resolution;
  uint lightCount;
};

struct LightData {
  float4 position;
  float4 color;
};

vertex VertexOut spriteVertex(ushort vid [[vertex_id]],
                              const device VertexIn* vert [[buffer(0)]],
                              constant Uniforms& uniforms [[buffer(1)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  outVertex.color = vertIn.color;
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment FragOutput spriteFragment(VertexOut interpolated [[stage_in]],
                               texture2d<float> tex2D [[texture(0)]],
                               texture2d<float> texLight [[texture(1)]],
                               sampler sampler2D [[sampler(0)]],
                               constant LightUniforms& lightUniforms [[buffer(0)]],
                               constant LightData& lights [[buffer(1)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  float4 normal = texLight.sample(sampler2D, interpolated.texCoord);

  float2 resolution = lightUniforms.resolution;

  float3 N = normalize(normal.xyz * 2.0 - 1.0);

  float3 intensity = lightUniforms.ambientColor;
  //for (int i = 0; i != lightUniforms.lightCount; i++) {
    //LightData lightData = lights[i];
  LightData lightData = lights;

    float3 lightDir = float3(lightData.position.xy - (interpolated.position.xy / resolution), lightData.position.z);
    lightDir.x *= resolution.x / resolution.y;
    //lightDir.x /= (1000.0 / resolution.x);
    //lightDir.y /= (1000.0 / resolution.y);

    float3 L = normalize(lightDir);

    float3 diffuse = lightData.color.xyz * max(dot(N, L), 0.0);

    float d = length(lightDir);
    //float attenuation = 1.0 / (0.4 + (3.0 * d) + (20.0 * d * d));
    float attenuation = (1.0 / (4.0 * d));

    intensity += diffuse * attenuation;
  //}

  //return float4(color.rgb * intensity, color.a);
  FragOutput output;
  output.diffuse = color;
  output.normal = normal;
  //output.diffuse = float4(color.rgb * intensity, color.a);
  return output;
}
