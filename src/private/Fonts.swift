//
//  Fonts.swift
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import UIKit

final class Fonts {
  //maybe add this to GEFonts at run time but need to preload somehow
  static let cache = Fonts()

  var device: MTLDevice!

  private var fontDict: [String: FontAtlas] = [:]

  private let pathName = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
  private let dirName = "gameengine.font.atlases"
  private var fontDir: NSURL? = nil

  init() {
    if let fontDir = pathName?.URLByAppendingPathComponent(dirName),
       let path = fontDir.path
    {
      if !NSFileManager.defaultManager().fileExistsAtPath(path) {
        do {
          try NSFileManager.defaultManager().createDirectoryAtURL(fontDir, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error {
          DLog("\(error) creating dir")
        }
      }
      self.fontDir = fontDir
    }
  }
  
  func fontForString(fontName: String, size: CGFloat) -> FontAtlas? {
    if let font = UIFont(name: fontName, size: size) {
      return fontForUIFont(font)
    }
    assert(false, fontName + " does not exist.")
    return nil
  }
  
  func fontForUIFont(font: UIFont) -> FontAtlas? {
    guard let fontDir = fontDir else { DLog("font directory doesn't exist"); return nil }

    if let atlas = fontDict[font.fontName] {
      return atlas
    }
    
    if let fontPath = fontDir.URLByAppendingPathComponent(font.fontName).path {
      let fontAtlas: FontAtlas
      if let archive = NSKeyedUnarchiver.unarchiveObjectWithFile(fontPath) as? GETextLabel {
        fontAtlas = archive as! FontAtlas
      }
      else if let archive = NSKeyedUnarchiver.unarchiveObjectWithFile(fontPath) as? FontAtlas {
        fontAtlas = archive
      }
      else {
        fontAtlas = FontAtlas(font: font)
        let data = NSKeyedArchiver.archivedDataWithRootObject(fontAtlas)
        data.writeToFile(fontPath, atomically: false)
      }

      fontDict[font.fontName] = fontAtlas

      return fontAtlas
    }
    assert(false, "wtf happend"); return nil
  }
}
