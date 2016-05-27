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
  packed_float2 texCoord [[attribute(1)]];
  packed_float2 pad;
};

struct InstanceUniforms {
  float4x4 model;
  float4 color;
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
                              ushort iid [[instance_id]],
                              const device VertexIn* vert [[buffer(0)]],
                              //const device VertexIn* texC [[buffer(3)]],
                              //constant InstanceUniforms* instanceUniforms [[buffer(1)]],
                              constant Uniforms& uniforms [[buffer(2)]])
{
  VertexIn vertIn = vert[vid];
  //InstanceUniforms instanceIn = instanceUniforms[iid];

  VertexOut outVertex;
//add the view back to the position calculation
  //outVertex.position = uniforms.projection * instanceIn.model * float4(vertIn.position);
  outVertex.position = uniforms.projection * uniforms.view * float4(vertIn.position);
  //outVertex.color = instanceIn.color;
  outVertex.color = float4(1,1,1,1);
  outVertex.texCoord = vertIn.texCoord;

  return outVertex;
}

fragment float4 spriteFragment(VertexOut interpolated [[stage_in]],
                               texture2d<float> tex2D [[texture(0)]],
                               sampler sampler2D [[sampler(0)]])
{
  float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
  return color * interpolated.color;
}
