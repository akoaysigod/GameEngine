import simd

struct Projection {
  fileprivate(set) var projection: Mat4

  init(size: Size) {
    projection = Mat4.orthographic(right: size.width, top: size.height)
  }

  mutating func update(_ size: Size) {
    projection = Mat4.orthographic(right: size.width, top: size.height)
  }
}
