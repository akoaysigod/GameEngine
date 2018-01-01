import Foundation

/// A collection of Math related helper functions.
public final class Math {
  /**
   Convert degrees to radians.

   - parameter d: The degrees to be converted.

   - returns: The equivalent radians.
   */
  public static func toRadians(degrees: Float) -> Float {
    return (Float(Double.pi) / 180.0) * degrees
  }
}
