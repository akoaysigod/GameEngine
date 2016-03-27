//
//  GETexture.swift
//  GameEngine
//
//  Created by Anthony Green on 3/19/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit



public class GETexture {
  let texture: MTLTexture

  public let width: Int
  public let height: Int
  var size: CGSize {
    return CGSize(width: width, height: height)
  }
  var frame: TextureFrame

  //for asynch loading
  //there's a different method on MTKTextureLoader for doing asynch stuff
  let callback: MTKTextureLoaderCallback?

  private static var errorTexture: MTLTexture {
    let url = NSBundle.mainBundle().URLForResource("error", withExtension: "png")!
    return try! Device.shared.textureLoader.newTextureWithContentsOfURL(url, options: nil)
  }

  init(texture: MTLTexture, callback: MTKTextureLoaderCallback? = nil) {
    self.texture = texture
    self.callback = callback

    self.width = texture.width
    self.height = texture.height

    self.frame = TextureFrame(x: 0, y: 0, sWidth: texture.width, sHeight: texture.height, tWidth: texture.width, tHeight: texture.height)
  }

  //not sure if there is a better way to handle this
  //it basically makes a copy with the same refs but different frames for using a GETextureAtlas
  init(texture: MTLTexture, frame: TextureFrame) {
    self.texture = texture
    self.width = Int(frame.sWidth)
    self.height = Int(frame.sHeight)
    self.frame = frame

    self.callback = nil
  }

  //TODO: not sure why but if you pass in an empty string it uses the last value used somehow
  public convenience init(named: String) {
    let texture: MTLTexture

    //need to think of a way around using UIImage
    guard let image = UIImage(named: named) else {
      DLog("\(named) not found")
      self.init(texture: GETexture.errorTexture)
      return
    }

    guard let data = UIImagePNGRepresentation(image) else {
      DLog("\(named) could not be turned into NSData")
      self.init(texture: GETexture.errorTexture)
      return
    }

    do {
      texture = try Device.shared.textureLoader.newTextureWithData(data, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(named): \(error)")
      texture = GETexture.errorTexture
    }

    self.init(texture: texture)
  }
}
