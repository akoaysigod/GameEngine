import Foundation
import Metal
import MetalKit

/**
 A `Texture` holds an image, essentially, to be applied to a `SpriteNode`.

 Currently these are being loaded synchronously using `MTKTextureLoader`.

 - seealso: `TextureAtlas`
 */
public class Texture: Hashable {
  let texture: MTLTexture
  let lightMapTexture: MTLTexture?

  // until I can figure out a nicer way to do this
  // I'm leaving this exposed so I can treat all atlases as if they're the same texture
  var uuid = UUID().uuidString
  public var hashValue: Int { return uuid.hashValue }

  public let width: Int
  public let height: Int
  public var size: Size {
    return Size(width: width, height: height)
  }
  let frame: TextureFrame

  //for asnych loading, there's a different method on MTKTextureLoader for doing asynch stuff
  let callback: MTKTextureLoader.Callback?

  /**
   Designated initalizer. 
   
   - note: This isn't exposed since it exposes Metal stuff.

   - parameter texture:  The actual GPU object texture.
   - parameter callback: A callback for when the texture has been loaded.

   - returns: A new instance of `Texture`.
   */
  init(texture: MTLTexture, lightMapTexture: MTLTexture? = nil, callback: MTKTextureLoader.Callback? = nil) {
    self.texture = texture
    self.lightMapTexture = lightMapTexture
    self.callback = callback

    self.width = texture.width
    self.height = texture.height

    self.frame = TextureFrame(x: 0, y: 0, sWidth: texture.width, sHeight: texture.height, tWidth: texture.width, tHeight: texture.height)
  }

  /**
   Creates a "copy" of an existing texture.
   
   - discussion: not sure if there is a better way to handle this
                 it basically makes a copy with the same refs but different frames for using a `TextureAtlas`

   - parameter texture: The texture ref to be copied.
   - parameter frame:   The frame to be used for the texture.

   - returns: A new/"copy" of `Texture`.
   */
  init(texture: MTLTexture, lightMapTexture: MTLTexture? = nil, frame: TextureFrame) {
    self.texture = texture
    self.lightMapTexture = lightMapTexture
    self.width = Int(frame.sWidth)
    self.height = Int(frame.sHeight)
    self.frame = frame

    self.callback = nil
  }
}

extension Texture: Equatable {
  public static func ==(rhs: Texture, lhs: Texture) -> Bool {
    return rhs.hashValue == lhs.hashValue
  }
}
