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
  }

  //TODO: not sure why but if you pass in an empty string it uses the last value used somehow
  convenience init(imageName: String) {
    let texture: MTLTexture

    guard let url = NSBundle.mainBundle().URLForResource(imageName, withExtension: "png") else {
      DLog("\(imageName) not found")
      self.init(texture: GETexture.errorTexture)
      return
    }

    do {
      texture = try Device.shared.textureLoader.newTextureWithContentsOfURL(url, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(imageName): \(error)")
      texture = GETexture.errorTexture
    }

    self.init(texture: texture)
  }
}
