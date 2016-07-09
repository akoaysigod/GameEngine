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

struct VertexOutput {
  float4 position [[position]];
};

struct LightData {
  float4 position;
  float4 color;
};

vertex VertexOutput lightVertex() {
  return VertexOutput();
}

fragment FragOutput lightFragment() {
  return FragOutput();
}
