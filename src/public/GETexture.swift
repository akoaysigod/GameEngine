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

  //for asynch loading
  let callback: MTKTextureLoaderCallback?

  private static var errorTexture: MTLTexture {
    let path = NSBundle.mainBundle().URLForResource("error", withExtension: "png")!
    return try! Device.shared.textureLoader.newTextureWithContentsOfURL(path, options: nil)
  }

  private init(texture: MTLTexture, callback: MTKTextureLoaderCallback? = nil) {
    self.texture = texture
    self.callback = callback
  }

  convenience init(imageName: String) {
    let texture: MTLTexture
    do {
      texture = try Device.shared.textureLoader.newTextureWithContentsOfURL(NSURL(string: "")!, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(imageName): \(error)")
      texture = GETexture.errorTexture
    }
    self.init(texture: texture)
  }
}
