import Metal
import MetalKit

/**
 A `SpriteNode` is a node that can be rendered with a `Texture`. The applied texture can also be blended with a color.
 */
open class SpriteNode: Node, Renderable {
  public var color: Color {
    didSet {
      updateTransform()
    }
  }
  public var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }
  public var texture: Texture?

  public var hidden = false
  public let isVisible = true

  var quad: Quad {
    let q = texture.flatMap { Quad.spriteRect(frame: $0.frame, color: color) } ?? Quad.rect(size: size, color: color)
    let vertices = q.vertices.map { vertex -> Vertex in
      let position = model * vertex.position
      return Vertex(position: position, st: vertex.st, color: color.vec4)
    }
    return Quad(vertices: vertices)
  }

  /**
   Designated initializer. Creates a new sprite object using an existing `Texture`.
   
   - discussion: The size should probably be the same as the texture size.

   - parameter texture: The texture to apply to the node.
   - parameter color:   The color to blend with the texture.
   - parameter size:    The size of node.

   - returns: A new instance of `SpriteNode`.
   */
  public required init(texture: Texture, color: Color, size: Size) {
    self.texture = texture
    self.color = color

    super.init(size: texture.size)
  }

  /**
   Convenience initializer.
   
   - discussion: This initializer sets the color property to white.

   - parameter texture: The texture to apply to the node.
   - parameter size:    The size of the node.

   - returns: A new instance of `SpriteNode`.
   */
  public convenience init(texture: Texture, size: Size) {
    self.init(texture: texture, color: .white, size: size)
  }

  /**
   Convenience initializer. 
   
   - discussion: This creates a node with the same size as the texture as well as defaulting the color to white.

   - parameter texture: The texture to apply to the node.

   - returns: A new instance of `SpriteNode`.
   */
  public convenience init(texture: Texture) {
    self.init(texture: texture, color: .white, size: texture.size)
  }

  override func updateTransform() {
    super.updateTransform()

    guard let key = texture?.hashValue else { return }

    scene?.updateNode(quad: quad, index: index, key: key)
  }
}
