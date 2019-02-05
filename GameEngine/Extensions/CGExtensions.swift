#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

public extension Float {
  var cg: CGFloat {
    return CGFloat(self)
  }
}

public extension CGFloat {
  var float: Float {
    return Float(self)
  }
}

/// This extension provides conveniences for using `Float`s with `CGPoint`s
public extension CGPoint {
  public var float: (x: Float, y: Float) {
    return (Float(self.x), Float(self.y))
  }

  public var point: Point {
    return Point(x: float.x, y: float.y)
  }

  /**
   An initializer for creating a `CGPoint` using `Float` values.

   - parameter x: The x value.
   - parameter y: The y value.

   - returns: A new instance of `CGPoint`.
   */
  public init(x: Float, y: Float) {
    self.init()
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
}

/// This extension provides conveniences for using `Float`s with `CGSize`
public extension CGSize {
  /// Get the width as a `Float`
  public var w: Float {
    return Float(width)
  }
  
  /// Get the height as a `Float`
  public var h: Float {
    return Float(height)
  }

  /// Convenience for hiding the CGFloat sizes
  public var size: Size {
    return Size(width: w, height: h)
  }

  /**
   Convenience initializer for creating a `CGSize` with `Float` values.

   - parameter width:  The width.
   - parameter height: The height.

   - returns: A new instance of `CGSize`.
   */
  public init(width: Float, height: Float) {
    self.init(width: Double(width), height: Double(height))
  }
}
