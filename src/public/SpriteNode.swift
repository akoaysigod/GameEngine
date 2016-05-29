//
//  Sprite.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Metal
import MetalKit

/**
 A `SpriteNode` is a node that can be rendered with a `Texture`. The applied texture can also be blended with a color.
 */
public class SpriteNode: Node, Renderable {
  public var color: Color {
    didSet {
      //add a thing to update buffer for color
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
    let q = texture.flatMap { Quad.spriteRect($0.frame, color: color) } ?? Quad.rect(size, color: color)
    let vertices = q.vertices.map { vertex -> Vertex in
      let position = transform * vertex.position
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

  /**
   Convenience initializer. 
   
   - discussion: This should really only be used for prototyping as this is the slowest and most memory intensive version.
                 It's pretty much used the same as `UIImage(named:)`. Unlike `UIImage`, however, it will force load an error image in the case 
                 that the given image name does not exist. Defaults size to image size and color to white.

   - parameter named: The name of the texture/image to be used.

   - returns: A new instance of `SpriteNote`.
   */
  public convenience init(named: String) {
    self.init(texture: Texture(named: named))
  }
}
