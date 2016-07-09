//
//  Structures.h
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

#ifndef Structures_h
#define Structures_h

#include <simd/simd.h>
namespace Structures {
  using namespace simd;
  
  typedef struct
  {
    float4 diffuse [[color(0)]];
    float4 normal  [[color(1)]];
    float4 light   [[color(2)]];
  } FragOutput;
}
#endif /* Structures_h */
