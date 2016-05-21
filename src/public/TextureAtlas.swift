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
    static let Size = "size"
  }

  private let jsonData: [String: AnyObject]
  private let texture: Texture
  public var textureNames: [String] {
    return Array(jsonData.keys)
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
