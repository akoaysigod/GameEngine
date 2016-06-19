//
//  Shaders.metal
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

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
  float3 lightPos;
};

vertex VertexOut spriteVertex(ushort vid [[vertex_id]],
                              const device VertexIn* vert [[buffer(0)]],
                              constant Uniforms& uniforms [[buffer(2)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  outVertex.color = vertIn.color;
  outVertex.texCoord = vertIn.texCoord;

  float4 lightPos = uniforms.projection * float4(0.0, 0.0, 0.0, 0.01);
  outVertex.lightPos = lightPos.xyz;

  return outVertex;
}

fragment float4 spriteFragment(VertexOut interpolated [[stage_in]],
                               texture2d<float> tex2D [[texture(0)]],
                               texture2d<float> texLight [[texture(1)]],
                               sampler sampler2D [[sampler(0)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  float4 normal = texLight.sample(sampler2D, interpolated.texCoord);

  float2 res = float2(414, 736);

  float3 lightColor = float3(0.67, 0.16, 0.0);
  float3 lightPos = float3(0.5, 0.5, 0.01);
  float3 lightDir = float3(lightPos.xy - (interpolated.position.xy / res), interpolated.lightPos.z);
  lightDir.x *= res.x / res.y;

  float3 N = normalize(normal.xyz * 2.0 - 1.0);
  float3 L = normalize(lightDir);

  float3 diffuse = lightColor * max(dot(N, L), 0.0);


  float3 lightColor2 = float3(0.0, 0.0, 0.5);
  float3 lightPos2 = float3(0.0, 0.5, 0.01);
  float3 lightDir2 = float3(lightPos2.xy - (interpolated.position.xy / res), lightPos2.z);
  lightDir2.x *= res.x / res.y;
  float3 L2 = normalize(lightDir2);

  float3 lightColor3 = float3(0.0, 0.5, 0.0);
  float3 lightPos3 = float3(0.5, 0.0, 0.01);
  float3 lightDir3 = float3(lightPos3.xy - (interpolated.position.xy / res), lightPos3.z);
  lightDir3.x *= res.x / res.y;
  float3 L3 = normalize(lightDir3);



  float3 ambientColor = float3(0.25, 0.25, 0.25);

  float d = length(lightDir);
  float d2 = length(lightDir2);
  float d3 = length(lightDir3);
  float attenuation2 = 1.0 / (0.4 + (3 * d2) + (20 * d2 * d2));

//+ ((1.0 / attenuation) * (lightColor2 * max(dot(N, L2), 0.0)))
  float3 intensity = ambientColor + (diffuse * (1.0 / (4 * d))) +
                    ((attenuation2 * 2) * (lightColor2 * max(dot(N, L2), 0.0))) +
                    ((1.0 / length_squared(5 * lightDir3)) * (lightColor3 * max(dot(N, L3), 0.0)));
  float3 finalColor = color.rgb * intensity;

  return float4(finalColor, color.a);
}
