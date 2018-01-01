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
  } FragOut;
}
#endif /* Structures_h */
