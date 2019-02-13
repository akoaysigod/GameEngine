#include <metal_stdlib>
#include "Structures.h"

using namespace metal;
using namespace Structures;

struct VertexIn {
  float4 position [[attribute(0)]];
  float4 color    [[attribute(1)]];
  float2 texCoord [[attribute(2)]];
  float2 pad;
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
                              constant Uniforms& uniforms [[buffer(1)]])
{
  VertexIn vertIn = vert[vid];

  VertexOut outVertex;
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  outVertex.color = vertIn.color;
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment FragOut spriteFragment(VertexOut interpolated [[stage_in]],
                                texture2d<float> texColor [[texture(0)]],
                                texture2d<float> texNormal [[texture(1)]],
                                sampler sampler2D [[sampler(0)]])
                                //constant float4& lightColor [[buffer(0)]]) //why is this being passed in here? 
{
  FragOut fragOut;
  fragOut.diffuse = texColor.sample(sampler2D, interpolated.texCoord);
  fragOut.normal = texNormal.sample(sampler2D, interpolated.texCoord);
  fragOut.light = float4(0.0, 0.0, 0.0, 0.0);
  //fragOut.light = lightColor;
  return fragOut;
}
