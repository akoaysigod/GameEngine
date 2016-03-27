//
//  GETextureAtlas.swift
//  GameEngine
//
//  Created by Anthony Green on 3/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import UIKit

public class GETextureAtlas {
  //from the resources/AtlasGen.py
  private struct Keys {
    static let Frame = "frame"
    static let Size = "size"
  }

  private let jsonData: [String: AnyObject]
  private let texture: GETexture
  public var textureNames: [String] {
    return Array(jsonData.keys)
  }

  public init?(named: String) {
    let scale = "\(Int(UIScreen.mainScreen().scale))"
    guard let jsonData = GETextureAtlas.loadJSONData(named, scale: "@" + scale + "x") else {
      return nil
    }
    self.jsonData = jsonData

    self.texture = GETexture(named: named)
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

  public func textureNamed(named: String) -> GETexture? {
    guard let data = jsonData[named] as? [String: AnyObject] else { return nil }
    guard let frameData = data["frame"] as? [String: AnyObject],
      let x = frameData["x"] as? Int,
      let y = frameData["y"] as? Int,
      let width = frameData["width"] as? Int,
      let height = frameData["height"] as? Int else { return nil }

    let frame = TextureFrame(x: x, y: y, sWidth: width, sHeight: height, tWidth: texture.width, tHeight: texture.height)
    return GETexture(texture: texture.texture, frame: frame)
  }
}