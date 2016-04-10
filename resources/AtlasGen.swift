#!/usr/bin/swift 

import Cocoa
import Foundation

typealias ImageData = [[String: AnyObject]]

class FileManager {
  let fm = NSFileManager.defaultManager()
  let inPath: String
  let outPath: String

  init(inPath: String, outPath: String) {
    self.inPath = inPath
    self.outPath = outPath

    if do() {
      updateRequired {
        try fm.createDirectoryAtPath(outPath, withIntermediateDirectories: false, attributes: nil)
      }
      catch let error as NSError {
        if error.code != 516 {
          print(error);
        }
      }
      deleteOldData()
      copyContentInfo()
    }
  }

  func updateRequired() -> Bool {
    guard let json = jsonLoader(inPath) else { return false }
    if let info = json["info"] as? [String: AnyObject],
       let _ = info["customVersion"] as? Int {
      return false
    }
    return true
  }

  func jsonLoader(path: String) -> [String: AnyObject]? {
    guard let jsonData = NSData(contentsOfFile: path + "/Contents.json") else { return nil }
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
      return json as? [String: AnyObject]
    }
    catch let error {
      print(error)
      return nil
    }
  }

  func getImageData() -> (two: ImageData, three: ImageData) {
    var two = ImageData()
    var three = ImageData()

    if let folders = fm.enumeratorAtPath(inPath) {
      let imageFolders = folders.filter { $0.hasSuffix("imageset") }
      let imagePaths = imageFolders.map { inPath + "/\($0)" }

      for imageSet in imagePaths {
        guard let contents = jsonLoader(imageSet) else { continue }
        guard let imageData = contents["images"] as? [[String: AnyObject]] else { continue }

        let filenames = imageData.filter { $0["filename"] != nil }
        var twoTimes = filenames.filter { ($0["scale"] as? String) == "2x" }.first
        twoTimes?["path"] = imageSet 
        var threeTimes = filenames.filter { ($0["scale"] as? String) == "3x" }.first
        threeTimes?["path"] = imageSet

        if let twoTimes = twoTimes {
          two += [twoTimes]
        }

        if let threeTimes = threeTimes {
          three += [threeTimes]
        }
      }
    }
    return (two: two, three: three)
  }

  func deleteOldData() {
    if let folders = fm.enumeratorAtPath(outPath) {
      folders.forEach {
        do {
          _ = try fm.removeItemAtPath(outPath + "/\($0 as! String)")
        }
        catch let error as NSError {
          print(error)
        }
      }
    }
  }

  func copyContentInfo() {
    let inPath = self.inPath + "/Contents.json"
    let outPath = self.outPath + "/Contents.json"
    
    do {
      _ = try fm.copyItemAtPath(inPath, toPath: outPath)
    }
    catch let error as NSError {
      if error.code == 516 { return }
      print(error)
    }
  }

  func genNewImageData(catalog: String, imageData: (ImageData, ImageData)) {
    //  let info: [String: AnyObject] = [
    //    "version": 1,
    //    "author": "xcode"
    //  ]
    //
    //  let empty = ["idiom": "universal", "scale": "1x"]
    //  let contents = [
    //    "images": [
    //      empty,
    //      imageData.0,
    //      imageData.1
    //    ],
    //    "info": info
    //  ]
  }
}

class AtlasGen {
  typealias Size = (w: Int, h: Int)

  let twoTimesData: ImageData
  let twoTimesSize: Size 
  let threeTimesData: ImageData
  let threeTimesSize: Size = (0, 0)

  init(imageData: (ImageData, ImageData)) {
    self.twoTimesData = imageData.0
    self.threeTimesData = imageData.1

    let twoTimesSamplePath = (twoTimesData.first!["path"] as! String) + "/" + (twoTimesData.first!["filename"] as! String)
    twoTimesSize = AtlasGen.calculateSize(twoTimesSamplePath)
  }

  static func calculateSize(filePath: String) -> Size {
    guard let data = NSData(contentsOfFile: filePath) else { return (0, 0) }
    var sizes = UnsafeMutablePointer<UInt32>.alloc(2)
    defer { sizes.destroy(2); sizes.dealloc(2) }
    data.getBytes(sizes, range: NSRange(location: 16, length: 8))                                      
    return (Int(CFSwapInt32(sizes[0])), Int(CFSwapInt32(sizes[1])))
  }

  func makeAtlas(isThree: Bool = false) {
    let singleSize: Int
    if isThree {
      singleSize = threeTimesSize.w
    }
    else {
      singleSize = twoTimesSize.w
    }

    let image = NSImage(size: CGSize(width: singleSize * 2, height: singleSize))

    let imagePathOne = (twoTimesData.first!["path"] as! String) + "/" + (twoTimesData.first!["filename"] as! String)
    let imageOneData = NSData(contentsOfFile: imagePathOne)!
    let imagePathTwo = (twoTimesData[1]["path"] as! String) + "/" + (twoTimesData[1]["filename"] as! String)
    let imageTwoData = NSData(contentsOfFile: imagePathTwo)!

    let imageOne = NSImage(data: imageOneData)!
    let imageTwo = NSImage(data: imageTwoData)!

    image.lockFocus()

    var rect = CGRect.zero
    imageOne.drawInRect(rect)
    imageTwo.drawInRect(rect)

    let png = image.representationUsingType(NSPNGFileType, properties: nil)
    png.writeToFile("./yay.png", atomically: false)
    
    image.unlockFocus()
    
    // let imageData = UnsafeMutablePointer<UInt8>.alloc(Int(size * size))
    // let colorSpace = CGColorSpaceCreateDeviceRGB()
    // let bitmapInfo = CGBitmapInfo.AlphaInfoMask.rawValue & CGImageAlphaInfo.Last.rawValue
    // let context = CGBitmapContextCreate(imageData, Int(size), Int(size), 8, Int(size), colorSpace, bitmapInfo)
  }
}

func main() {
  guard Process.arguments.count > 1 else {
    print("\(Process.arguments.first!) xcassetsIn xcassetsOut")
    return
  }


  let inPath = Process.arguments[1]
  let outPath = Process.arguments[2]

  let fileManager = FileManager(inPath: inPath, outPath: outPath)

  guard fileManager.updateRequired() else { return }

  let imageData = fileManager.getImageData()

  let atlasGen = AtlasGen(imageData: imageData)
  atlasGen.makeAtlas()
}

main()
