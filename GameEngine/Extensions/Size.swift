import Foundation

/**
 A struct for storing size properties.
 */
public struct Size {
  /// a value representing a width
  public var width: Float
  /// a value representing a height
  public var height: Float

  var vec2: Vec2 {
    return Vec2(width, height)
  }

  public init(width: Float, height: Float) {
    self.width = width
    self.height = height
  }

  public init(width: Int, height: Int) {
    self.init(width: Float(width), height: Float(height))
  }
}

extension Size {
  /// Create a size with zero width and height.
  public static let zero = Size(width: 0.0, height: 0.0)
}
