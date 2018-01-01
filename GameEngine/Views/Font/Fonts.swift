import Foundation
import Metal
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

final class Fonts {
  //maybe add this to GEFonts at run time but need to preload somehow
  static let cache = Fonts()

  var device: MTLDevice!

  fileprivate var fontDict: [String: FontAtlas] = [:]

  fileprivate let pathName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
  fileprivate let dirName = "gameengine.font.atlases"
  fileprivate var fontDir: URL? = nil

  init() {
    if let fontDir = pathName?.appendingPathComponent(dirName) {
      if !FileManager.default.fileExists(atPath: fontDir.path) {
        do {
          try FileManager.default.createDirectory(at: fontDir, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error {
          DLog("\(error) creating dir")
        }
      }
      self.fontDir = fontDir
    }
  }
  
  func fontForString(_ fontName: String, size: CGFloat) -> FontAtlas? {
    if let font = Font(name: fontName, size: size) {
      return fontForUIFont(font)
    }
    assert(false, fontName + " does not exist.")
    return nil
  }
  
  func fontForUIFont(_ font: Font) -> FontAtlas? {
    guard let fontDir = fontDir else { DLog("font directory doesn't exist"); return nil }

    if let atlas = fontDict[font.fontName] {
      return atlas
    }
    
    let fontPath = fontDir.appendingPathComponent(font.fontName).path
    let fontAtlas: FontAtlas
    // if let archive = NSKeyedUnarchiver.unarchiveObjectWithFile(fontPath) as? GETextLabel {
    //   fontAtlas = archive as! FontAtlas
    // }
    // else
    if let archive = NSKeyedUnarchiver.unarchiveObject(withFile: fontPath) as? FontAtlas {
      fontAtlas = archive
    }
    else {
      fontAtlas = FontAtlas(font: font)
      let data = NSKeyedArchiver.archivedData(withRootObject: fontAtlas)
      try? data.write(to: URL(fileURLWithPath: fontPath), options: [])
    }

    fontDict[font.fontName] = fontAtlas

    return fontAtlas
  }
}
