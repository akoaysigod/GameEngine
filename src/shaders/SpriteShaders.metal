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
  float3 lightPos = float3(0.25, 0.25, 0.75);
  float3 lightDir = float3(lightPos.xy - (interpolated.position.xy / res), lightPos.z);
  lightDir.xy *= res.x / res.y;

  float4 lightColor = float4(0.65, 0.16, 0.0, 1.0);

  float d = length(lightDir);

  float3 N = normalize(normal.xyz);
  float3 L = normalize(lightDir.xyz);

  float3 diffuse = (lightColor.rgb * lightColor.a) * max(dot(N, L), 0.0);

  float4 ambientColor = float4(0.25, 0.25, 0.25, 1.0);
  float3 ambient = ambientColor.rgb * ambientColor.a;

  float3 falloff = float3(0.3, 3, 10);
  //float attenutation = 1.0 / (falloff.x / (falloff.x + (falloff.y * d) + (falloff.z * d * d)));
  float attenuation = 3.0;
  float3 intensity = ambient + diffuse * attenuation;
  float3 finalColor = color.rgb * intensity;

  return float4(finalColor, color.a);
}
