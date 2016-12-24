//
//  TextureAtlas.swift
//  GameEngine
//
//  Created by Anthony Green on 3/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

enum AtlasCreation: Error {
  case oneImage
  case missingImage
  case dimensions
  case tooLarge(String)
}

/**
 A `TextureAtlas` is an object that contains multiple textures to be loaded and used as one texture.
 
 This creates the atlas in memory as a `MTLTexture`.
 
 - note: Since packing stuff is hard this only works for images with the same dimensions.
 */
public final class TextureAtlas {
  fileprivate let data: [String: Rect]
  fileprivate let texture: Texture
  fileprivate let lightMapTexture: Texture?
  public let textureNames: [String]

  /**
   Given an array of images store in an xcasset this will create a new texture with all the textures in it.

   - parameter imageNames: The name of the images to create the atlas from.

   - returns: A new texture atlas.
   */
  public init(imageNames: [String], contentScale: CGFloat, createLightMap: Bool = false) throws {
    //should probably refactor this a bit at some point
    guard imageNames.count > 1 else {
      throw AtlasCreation.oneImage
    }

    let images = imageNames.flatMap { Texture(named: $0, contentScale: contentScale) }

    guard images.count == imageNames.count else {
      throw AtlasCreation.missingImage
    }

    guard let width = images.first?.width,
          let height = images.first?.height, width == height else {
      throw AtlasCreation.dimensions
    }

    let (rows, columns) = TextureAtlas.factor(images.count)

    guard rows * height < 4096 && columns * width < 4096 else {
      throw AtlasCreation.tooLarge("\(rows * height) by \(columns * width) is probably to large to load into the gpu.")
    }
    
    let tex = Texture.newTexture(columns * width, height: rows * height)

    var x = 0
    var y = 0
    var data  = [String: Rect]()
    zip(images, imageNames).forEach { (image, name) in
      let r = MTLRegionMake2D(x, y, width, height)

      let bytesPerRow = width * 4 //magic number sort of I'm assuming the format is 4 bytes per pixel
      var buffer = [UInt8](repeating: 0, count: width * height * 4)
      let lr = MTLRegionMake2D(0, 0, image.width, image.height)
      image.texture.getBytes(&buffer, bytesPerRow: bytesPerRow, from: lr, mipmapLevel: 0)

      tex.replace(region: r, mipmapLevel: 0, withBytes: buffer, bytesPerRow: bytesPerRow)

      data[name] = Rect(x: x, y: y, width: width, height: height)

      x += width
      if x >= columns * width {
        x = 0
        y += height
      }
    }

    texture = Texture(texture: tex)
    textureNames = imageNames
    self.data = data

    lightMapTexture = TextureAtlas.createLightMap(createLightMap, texture: texture)
  }

  fileprivate static func factor(_ i: Int) -> (rows: Int, columns: Int) {
    let stop = Int(Float(i) / 2.0)
    var d = 2

    var div = [(Int, Int)]()
    while d < stop {
      if i % d == 0 {
        div += [(d, i / d)]
      }
      d += 1
    }

    if div.count > 1 {
      let mins = div.map { max($0.0, $0.1) - min($0.0, $0.1) }
      let z = zip(mins, Array(0..<div.count)).sorted { $0.0 < $0.1 }
      return div[z[0].1]
    }
    else if div.count == 1 {
      return (div[0].0, div[0].1)
    }
    return factor(i + 1)
  }

  static func createLightMap(_ shouldCreateLightMap: Bool, texture: Texture) -> Texture? {
    guard shouldCreateLightMap else { return nil }

    let renderer = ComputeRenderer(srcTexture: texture)
    return renderer.generateTexture()
  }

  /**
   "Unpack" a texture from the atlas with a given name.

   - parameter name: The name of the texture to get.

   - returns: A `Texture` "copy" from the atlas.
   */
  public subscript(name: String) -> Texture? {
    return textureNamed(name)
  }

  /**
   "Unpack" a texture from the atlas with a given name.
   
   - parameter named: The name of the texture to get.

   - returns: A `Texture` "copy" from the atlas.
   */
  public func textureNamed(_ named: String) -> Texture? {
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
