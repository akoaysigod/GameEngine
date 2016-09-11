//
//  Texture.swift
//  GameEngine
//
//  Created by Anthony Green on 3/19/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public func ==(rhs: Texture, lhs: Texture) -> Bool {
  return rhs.hashValue == lhs.hashValue
}

/**
 A `Texture` holds an image, essentially, to be applied to a `SpriteNode`.

 Currently these are being loaded synchronously using `MTKTextureLoader`.

 - seealso: `TextureAtlas`
 */
open class Texture: Hashable, Equatable {
  let texture: MTLTexture
  let lightMapTexture: MTLTexture?

  // until I can figure out a nicer way to do this
  // I'm leaving this exposed so I can treat all atlases as if they're the same texture
  var uuid = UUID().uuidString
  open var hashValue: Int { return uuid.hashValue }

  open let width: Int
  open let height: Int
  open var size: Size {
    return Size(width: width, height: height)
  }
  let frame: TextureFrame

  //for asnych loading, there's a different method on MTKTextureLoader for doing asynch stuff
  let callback: MTKTextureLoaderCallback?

  /// if a bad image name was given or a texture couldn't be loaded for whatever reason fallback to this error image.
  fileprivate static var errorTexture: MTLTexture {
    let url = Bundle.main.url(forResource: "error", withExtension: "png")!
    return try! Device.shared.textureLoader.newTexture(withContentsOf: url, options: nil)
  }

  /**
   Designated initalizer. 
   
   - note: This isn't exposed since it exposes Metal stuff.

   - parameter texture:  The actual GPU object texture.
   - parameter callback: A callback for when the texture has been loaded.

   - returns: A new instance of `Texture`.
   */
  init(texture: MTLTexture, lightMapTexture: MTLTexture? = nil, callback: MTKTextureLoaderCallback? = nil) {
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

  /**
   Creates a new `Texture` object given a name of an image.
   
   - warning: not sure why but if you pass in an empty string it uses the last value used somehow
              I still need to figure this weirdness out.
   
   - discussion: This is loading a `UIImage` to create a texture so passing it names from an xcasset will work.
                 I'm not sure if there is a better way to do this as `UIImage` get cached and you should be handlin the caching of 
                 these `Texture` objects manually.

   - parameter named: The name of the texture to be used.

   - returns: A new instance of `Texture`.
   */
  public convenience init(named: String) {
    let texture: MTLTexture

    guard let image = UIImage(named: named) else {
      DLog("\(named) not found")
      self.init(texture: Texture.errorTexture, lightMapTexture: nil)
      return
    }

    guard let data = UIImagePNGRepresentation(image) else {
      DLog("\(named) could not be turned into NSData")
      self.init(texture: Texture.errorTexture, lightMapTexture: nil)
      return
    }

    do {
      texture = try Device.shared.textureLoader.newTexture(with: data, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(named): \(error)")
      texture = Texture.errorTexture
    }

    self.init(texture: texture, lightMapTexture: nil)
  }
}

extension Texture {
  static func newTexture(_ width: Int, height: Int, pixelFormat: MTLPixelFormat) -> MTLTexture {
    let descriptor = MTLTextureDescriptor()
    descriptor.width = width
    descriptor.height = height
    descriptor.pixelFormat = pixelFormat
    return Device.shared.device.makeTexture(descriptor: descriptor)
  }
}
