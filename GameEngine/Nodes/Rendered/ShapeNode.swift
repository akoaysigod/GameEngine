import Metal

/**
 A `ShapeNode` is a node for creating colored shapes. Currently only supports rectangular shapes.
 */
open class ShapeNode: Node, Renderable {
  open var color: Color
  open var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }

  var texture: Texture? = nil

  open var hidden = false
  open let isVisible = true

  private(set) var quad: Quad

  /**
   Designated initializer. Creates a rectangular shape node of a given color.

   - parameter width:  The width of the shape.
   - parameter height: The height of the shape.
   - parameter color:  The color of the shape.

   - returns: A new instance of a rectangular `ShapeNode`.
   */
  public init(width: Float, height: Float, color: Color) {
    self.color = color
    quad = Quad.rect(width: width, height: height, color: color)

    super.init(size: Size(width: width, height: height))
  }

  /**
   Convenience init. Creates a rectangular shape node of a given color.
   
   - discussion: Most of this engine uses `Float` but Swift likes to default numbers to `Doubles`.

   - parameter width:  The width of the shape.
   - parameter height: The height of the shape.
   - parameter color:  The color of the shape.

   - returns: A new instance of `ShapeNode`.
   */
  public convenience init<T: ExpressibleByFloatLiteral>(width: T, height: T, color: Color) {
    self.init(width: width, height: height, color: color)
  }

  /**
   Convenience initializer. Creates a rectangular shape node of a given color.
   
   - parameter size:  The size of the shape.
   - parameter color: The color of the shape.

   - returns: A new instance of a rectangular `ShapeNode`.
   */
  public convenience init(size: Size, color: Color) {
    self.init(width: Float(size.width), height: Float(size.height), color: color)
  }
}
