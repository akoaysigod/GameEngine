public func +=(p: inout Point, rhs: Point) {
  p.x += rhs.x
  p.y += rhs.y
}

public struct Point {
  public var x: Float
  public var y: Float

  public init(x: Float, y: Float) {
    self.x = x
    self.y = y
  }

  public init(x: Int, y: Int) {
    self.init(x: Float(x), y: Float(y))
  }
}

extension Point {
  /// Create a point with 0.0 for both elements
  public static let zero = Point(x: 0.0, y: 0.0)
}
