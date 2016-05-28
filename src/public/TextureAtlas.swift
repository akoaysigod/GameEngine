//
//  TextureAtlas.swift
//  GameEngine
//
//  Created by Anthony Green on 3/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import UIKit

/**
 A `TextureAtlas` is an object that contains multiple textures to be loaded and used as one texture.
 
 Since this engine is tile based I wrote a rather inefficient texture packing script to be insert into the build phase. 
 It creates two new xcassets from an existing one that packs all the sprites together and creates the JSON data. 
 
 - seealso: ${PROJECT_DIR}/resources/README.md and `AtlasGen.py` in the same directory.
 */
public class TextureAtlas {
  //from the resources/AtlasGen.py
  private struct Keys {
    static let Frame = "frame"
    static let X = "x"
    static let Y = "y"
    static let Width = "width"
    static let Height = "height"
  }

  private let jsonData: [String: AnyObject]
  private let texture: Texture
  public var textureNames: [String] {
    return Array(jsonData.keys)
  }

  public init?(imageNames: [String]) {
    guard imageNames.count > 1 else {
      DLog("Kind of pointless to make an atlas with one image.")
      return nil
    }


    let images = imageNames.flatMap { Texture(named: $0) }

    guard images.count == imageNames.count else {
      DLog("Missing image.")
      return nil
    }

    guard let width = images.first?.width,
          let height = images.first?.height,
          let pixelFormat = images.first?.texture.pixelFormat where width == height else {
        DLog("Images should have the same dimensions.")
        return nil
    }

    let (rows, columns) = TextureAtlas.factor(images.count)
    let tex = Texture.newTexture(columns * width, height: rows * height, pixelFormat: pixelFormat)

    var x = 0
    var y = 0
    var data  = [String: AnyObject]() //change this AnyObject to a struct when this is done
    zip(images, imageNames).forEach { (image, name) in
      let r = MTLRegionMake2D(x, y, width, height)

      let bytesPerRow = width * 4 //magic number sort of I'm assuming the format is 4 bytes per pixel
      var buffer = [UInt8](count: width * height * 4, repeatedValue: 0)
      let lr = MTLRegionMake2D(0, 0, image.width, image.height)
      image.texture.getBytes(&buffer, bytesPerRow: bytesPerRow, fromRegion: lr, mipmapLevel: 0)

      tex.replaceRegion(r, mipmapLevel: 0, withBytes: buffer, bytesPerRow: bytesPerRow)

      data[name] = [
        Keys.Frame: [
          Keys.Height: height,
          Keys.Width: width,
          Keys.X: x,
          Keys.Y: y
        ]
      ]

      x += width
      if x >= columns * width {
        x = 0
        y += height
      }
    }

    texture = Texture(texture: tex)
    jsonData = data
  }

  private static func factor(i: Int) -> (rows: Int, columns: Int) {
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
      let z = zip(mins, Array(0..<div.count)).sort { $0.0 < $0.1 }
      return div[z[0].1]
    }
    else if div.count == 1 {
      return (div[0].0, div[0].1)
    }
    return factor(i + 1)
  }

  /**
   Designated failable initializer. Creates a new texture atlas with corresponding data to "unpack" it.
   
   - note: The name parameter will correspond to a group in your regular xcasset. If no groups are specified the name defaults to "Atlas".

   - discussion: This will fail if not using the scripts in ${PROJECT_DIR}/resources or if the manually generated xcasset does not match the format.

   - parameter named: The name of the atlas to be used. Can be found in the output of the generated xcasset.

   - returns: A new instance of `TextureAtlas`.
   */
  public init?(named: String) {
    let scale = "\(Int(UIScreen.mainScreen().scale))"
    guard let jsonData = TextureAtlas.loadJSONData(named, scale: "@" + scale + "x") else {
      return nil
    }

    self.jsonData = jsonData
    self.texture = Texture(named: named)
  }

  private static func loadJSONData(name: String, scale: String) -> [String: AnyObject]? {
    guard let asset = NSDataAsset(name: name + scale) else { return nil }

    do {
      let data = try NSJSONSerialization.JSONObjectWithData(asset.data, options: [])
      return data as? [String: AnyObject]
    }
    catch let error {
      DLog("Error loading atlas data \(error)")
      return nil
    }
  }

  /**
   "Unpack" a texture from the atlas with a given name.
   
   - parameter named: The name of the texture to get.

   - returns: A `Texture` "copy" from the atlas.
   */
  public func textureNamed(named: String) -> Texture? {
    guard let data = jsonData[named] as? [String: AnyObject] else {
      DLog("\(named) does not exist in atlas.")
      return nil
    }

    guard let frameData = data["frame"] as? [String: AnyObject],
      let x = frameData["x"] as? Int,
      let y = frameData["y"] as? Int,
      let width = frameData["width"] as? Int,
      let height = frameData["height"] as? Int else {
        DLog("\(named)'s data does not exist in atlas.")
        return nil
    }

    let frame = TextureFrame(x: x, y: y, sWidth: width, sHeight: height, tWidth: texture.width, tHeight: texture.height)
    let ret = Texture(texture: texture.texture, frame: frame)
    ret.uuid = texture.uuid
    return ret
  }
}
