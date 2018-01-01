#include <metal_stdlib>
using namespace metal;

//Dx is left column then right column
//Dy is top row then bottom row
struct Convolutions {
  float2x3 dx;
  float2x3 dy;
};

//
//constant float dXSobel[] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
//constant float dYSobel[] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};

static half avg(texture2d<half, access::sample> sTex, sampler samp, float2 st, int2 offset) {
  half4 c = sTex.sample(samp, st, offset);
  //return (c.r * 0.21) + (c.g * 0.72) + (c.b * 0.07);
  return (c.r + c.g + c.b) / 3.0h;
}

kernel void normal(texture2d<half, access::sample> sTex [[texture(0)]],
                   texture2d<half, access::write> dTex [[texture(1)]],
                   sampler samp [[sampler(0)]],
                   constant Convolutions& convolutions [[buffer(0)]],
                   uint2 gridPos [[thread_position_in_grid]]) {
  float2 st = float2(gridPos);

  half ul = avg(sTex, samp, st, int2(-1, 1));
  half u = avg(sTex, samp, st, int2(0, 1));
  half ur = avg(sTex, samp, st, int2(1, 1));

  half l = avg(sTex, samp, st, int2(-1, 0));
  half r = avg(sTex, samp, st, int2(1, 0));

  half dl = avg(sTex, samp, st, int2(-1, -1));
  half d = avg(sTex, samp, st, int2(0, -1));
  half dr = avg(sTex, samp, st, int2(1, -1));

//  half red = ((ur + 2.0h * r + dr) - (ul + 2.0h * l + dl));
//  half green = ((dl + 2.0h * d + dr) - (ul + 2.0h * u + ur));
//  half red = ((3.0h * ur + 10.0h * r + 3.0h * dr) - (3.0h * ul + 10.0h * l + 3.0h * dl));
//  half green = ((3.0h * dl + 10.0h * d + 3.0h * dr) - (3.0h * ul + 10.0h * u + 3.0h * ur));

  half red = dot(half3(ur, r, dr), (half3)convolutions.dx[1]) + dot(half3(ul, l, dl), (half3)convolutions.dx[0]);
  half green = dot(half3(dl, d, dr), (half3)convolutions.dy[1]) + dot(half3(ul, u, ur), (half3)convolutions.dy[0]);
  half a = sTex.sample(samp, st).a;

  dTex.write(half4(red * 0.5h + 0.5h, green * 0.5h + 0.5h, 1.0h, a), gridPos);
}
