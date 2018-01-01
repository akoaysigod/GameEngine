import Foundation
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

enum AtlasCreation: Error {
  case dimensions
  case tooLarge(String)
}

/**
 A `TextureAtlas` is an object that contains multiple textures to be loaded and used as one texture.
 
 This creates the atlas in memory as a `MTLTexture`.
 
 - note: Since packing stuff is hard this only works for images with the same dimensions.
 */
public final class TextureAtlas {
  private let data: [String: Rect]
  private let texture: Texture
  private let lightMapTexture: Texture?
  public let textureNames: [String]

  init(data: [String: Rect], texture: Texture, lightMapTexture: Texture?, textureNames: [String]) {
    self.data = data
    self.texture = texture
    self.lightMapTexture = lightMapTexture
    self.textureNames = textureNames
  }

  /**
   "Unpack" a texture from the atlas with a given name.

   - parameter name: The name of the texture to get.

   - returns: A `Texture` "copy" from the atlas.
   */
  public subscript(name: String) -> Texture? {
    return texture(named: name)
  }

  /**
   "Unpack" a texture from the atlas with a given name.
   
   - parameter named: The name of the texture to get.

   - returns: A `Texture` "copy" from the atlas.
   */
  public func texture(named: String) -> Texture? {
    guard let rect = data[named] else {
      DLog("\(named) does not exist in atlas.")
      return nil
    }

    let frame = TextureFrame(x: Int(rect.x),
                             y: Int(rect.y),
                             sWidth: Int(rect.width),
                             sHeight: Int(rect.height),
                             tWidth: texture.width,
                             tHeight: texture.height)
    let ret = Texture(texture: texture.texture, lightMapTexture: lightMapTexture?.texture, frame: frame)
    ret.uuid = texture.uuid
    return ret
  }
}
