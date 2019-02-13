#include <metal_stdlib>
#include "Structures.h"

using namespace metal;
using namespace Structures;

//struct VertexIn {
//  float4 position [[attribute(0)]];
//};

struct VertexIn {
  float4 position [[attribute(0)]];
};

struct Uniforms {
  float4x4 projection;
  float4x4 view;
};

struct VertexOut {
  float4 position [[position]];
};

struct LightData {
  float2 position;
  float4 color;
  float radius;
};

vertex VertexOut lightVertex(ushort vid [[vertex_id]],
                             const device VertexIn* vert [[buffer(0)]],
                             constant Uniforms& uniforms [[buffer(1)]]) {
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);

  return outVertex;
}

fragment float4 lightFragment(VertexOut interpolated [[stage_in]],
                               constant float2& resolution [[buffer(0)]],
                               constant LightData& lightData [[buffer(1)]],
                               FragOut gBuffer)
{
  float3 lightDir = float3(lightData.position - (interpolated.position.xy / resolution), 0.01);
  lightDir.x *= resolution.x / resolution.y;
  //lightDir.x /= (1000.0 / resolution.x);
  //lightDir.y /= (1000.0 / resolution.y);

  float3 l = normalize(lightDir);
  float3 n = normalize(gBuffer.normal.xyz * 2.0 - 1.0);
  float3 diffuse = lightData.color.xyz * max(dot(n, l), 0.0);

  float d = length(lightDir);
  //float attenuation = 1.0 / (0.4 + (3.0 * d) + (20.0 * d * d));
  float attenuation = (1.0 / (4.0 * d));

  float4 light = gBuffer.light;
  light.rgb += diffuse * attenuation;

  FragOut fragOut;
  fragOut.diffuse = gBuffer.diffuse * light;
  fragOut.normal = gBuffer.normal;
  gBuffer.light = light;

  // mostly works right now, maybe don't need to add the diffuse color it looks fine but it's dark
  //return float4(gBuffer.diffuse.rgb * diffuse * attenuation, gBuffer.diffuse.a);
  return float4(gBuffer.light.rgb, gBuffer.diffuse.a);
}
