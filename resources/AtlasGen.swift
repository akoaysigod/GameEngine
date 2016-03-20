#!/usr/bin/swift 

import Foundation

typealias ImageData = [[String: AnyObject]]

let fm = NSFileManager.defaultManager()

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

func updateRequired(catalog: String) -> Bool {
  guard let json = jsonLoader(catalog) else { return false }
  if let info = json["info"] as? [String: AnyObject],
     let _ = info["customVersion"] as? Int {
    return false
  }
  return true
}

func getImageData(catalog: String) -> (two: ImageData, three: ImageData) {
  var two = ImageData()
  var three = ImageData()

  if let folders = fm.enumeratorAtPath(catalog) {
     let imageFolders = folders.filter { $0.hasSuffix("imageset") }
     let imagePaths = imageFolders.map { catalog + "/\($0)" }

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

func deleteOldData(outPath: String) {
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

func genContentsInfo(inPath: String, outPath: String) {
  let inPath = inPath + "/Contents.json"
  let outPath = outPath + "/Contents.json"
  
  do {
    _ = try fm.copyItemAtPath(inPath, toPath: outPath)
  }
  catch let error as NSError {
    if error.code == 516 { return }
    print(error)
  }
}

func genNewImageData(catalog: String, imageData: (ImageData, ImageData)) {
  
}

func main() {
  guard Process.arguments.count > 1 else {
    print("\(Process.arguments.first!) xcassetsIn xcassetsOut")
    return
  }

  let catalogPath = Process.arguments[1]
  let outPath = Process.arguments[2]

  guard updateRequired(catalogPath) else { return }
  let imageData = getImageData(catalogPath)

  do {
    try fm.createDirectoryAtPath(outPath, withIntermediateDirectories: false, attributes: nil)
  }
  catch let error as NSError {
    if error.code != 516 {
      print(error);
    }
  } 

  deleteOldData(outPath)
  genContentsInfo(catalogPath, outPath: outPath)
  genNewImageData(outPath, imageData: imageData)
}

main()
