//
//  FontAtlas.swift
//  GameEngine
//
//  Created by Anthony Green on 2/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import CoreText
import Foundation
import UIKit

//maybe private
final class GlyphDescriptor: NSObject, NSCoding {
  let glyphIndex: CGGlyph
  let topLeftTexCoord: CGPoint
  let bottomRightTexCoord: CGPoint

  init(glyphIndex: CGGlyph, topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
    self.glyphIndex = glyphIndex
    self.topLeftTexCoord = topLeftTexCoord
    self.bottomRightTexCoord = bottomRightTexCoord
  }

  fileprivate struct Keys {
    static let GlyphIndex = "glyphindex"
    static let XLeftTex = "xlefttex"
    static let YLeftTex = "ylefttex"
    static let XRightTex = "xrighttex"
    static let YRightTex = "yrighttex"
  }

  required init?(coder aDecoder: NSCoder) {
    self.glyphIndex = UInt16(aDecoder.decodeCInt(forKey: Keys.GlyphIndex))

    let lx = aDecoder.decodeFloat(forKey: Keys.XLeftTex)
    let ly = aDecoder.decodeFloat(forKey: Keys.YLeftTex)
    self.topLeftTexCoord = CGPoint(x: lx, y: ly)

    let rx = aDecoder.decodeFloat(forKey: Keys.XRightTex)
    let ry = aDecoder.decodeFloat(forKey: Keys.YRightTex)
    self.bottomRightTexCoord = CGPoint(x: rx, y: ry)
  }

  func encode(with coder: NSCoder) {
    coder.encodeCInt(Int32(glyphIndex), forKey: Keys.GlyphIndex)
    coder.encode(Float(topLeftTexCoord.x), forKey: Keys.XLeftTex)
    coder.encode(Float(topLeftTexCoord.y), forKey: Keys.YLeftTex)
    coder.encode(Float(bottomRightTexCoord.x), forKey: Keys.XRightTex)
    coder.encode(Float(bottomRightTexCoord.y), forKey: Keys.YRightTex)
  }
}

private final class FlatArray<T> {
  var arr: [T]
  fileprivate let width: Int
  
  init(count: Int, repeatedValue: T, width: Int) {
    self.arr = [T](repeating: repeatedValue, count: count)
    self.width = width
  }
  
  subscript(x: Int, y: Int) -> T {
    get {
      return arr[y * width + x]
    }
    set {
      arr[y * width + x] = newValue
    }
  }
}

class FontAtlas: NSObject, NSCoding {
  //these probably have to be the same right now
  fileprivate struct Constants {
    static let AtlasSizeHeightMax = 4096
    static let AtlasSizeWidthMax = 4096
    static let AsciiHeight = 4096
    static let AsciiWidth = 4096
  }
  
  let font: UIFont
  let textureSize: Int
  var textureData: Data!
  var glyphDescriptors = [GlyphDescriptor]()

  #if DEBUG
  var debugImage: UIImage?
  #endif
  
  var asciiOnly = true
  
  init(font: UIFont, textureSize: Int) {
    self.font = font
    self.textureSize = textureSize

    super.init()

    createTextureData()
  }

  //not sure yet
  convenience init(font: UIFont) {
    self.init(font: font, textureSize: Constants.AsciiWidth / 2)
  }

  //MARK: NSCODING
  fileprivate struct Keys {
    static let Font = "font"
    static let FontSize = "size"
    static let Spread = "spread"
    static let Width = "width"
    static let Height = "height"
    static let TextureSize = "texturesize" //this is just height or width really...
    static let TextureData = "texturedata"
    static let GlyphDescriptors = "glyphdescriptors"
  }

  required init?(coder aDecoder: NSCoder) {
    let fontName = aDecoder.decodeObject(forKey: Keys.Font) as! String
    let fontSize = aDecoder.decodeFloat(forKey: Keys.FontSize)
    //let fontSpread = aDecoder.decodeFloatForKey(Keys.Spread)

    self.font = UIFont(name: fontName, size: CGFloat(fontSize))!
    self.textureSize = Int(aDecoder.decodeCInt(forKey: Keys.TextureSize))
    self.textureData = aDecoder.decodeObject(forKey: Keys.TextureData) as! Data
    self.glyphDescriptors = aDecoder.decodeObject(forKey: Keys.GlyphDescriptors) as! [GlyphDescriptor]
    
    super.init()
  }

  func encode(with coder: NSCoder) {
    coder.encode(font.fontName, forKey: Keys.Font)
    coder.encode(Float(font.pointSize), forKey: Keys.FontSize)
    coder.encodeCInt(Int32(textureSize), forKey: Keys.TextureSize)
    coder.encode(textureData, forKey: Keys.TextureData)
    coder.encode(glyphDescriptors, forKey: Keys.GlyphDescriptors)
  }
  
  //TODO: rewrite these estimates
  fileprivate func estimateGlyphSize(_ font: UIFont) -> CGSize {
    let exampleStr: NSString = "123ABC"
    let exampleStrSize = exampleStr.size(attributes: [NSFontAttributeName: font])
    let averageWidth = ceil(exampleStrSize.width / CGFloat(exampleStr.length))
    let maxHeight = ceil(exampleStrSize.height)
    return CGSize(width: averageWidth, height: maxHeight)
  }
  
  fileprivate func estimateLineWidth(_ font: UIFont) -> CGFloat {
    let estimatedWidth = ("!" as NSString).size(attributes: [NSFontAttributeName: font]).width
    return ceil(estimatedWidth)
  }
  
  fileprivate func willLikelyFitInAtlasRect(_ font: UIFont, size: CGFloat, rect: CGRect) -> Bool {
    let textureArea = rect.size.width * rect.size.height
    let testFont = UIFont(name: font.fontName, size: size)!
    let testCTFont = CTFontCreateWithName(font.fontName as CFString?, size, nil)
    let fontCount = glyphIndices(testCTFont).count//CTFontGetGlyphCount(testCTFont)
    
    let margin = self.estimateLineWidth(testFont)
    let averageSize = self.estimateGlyphSize(testFont)
    
    let estimatedTotalArea = (averageSize.width + margin) * (averageSize.height + margin) * CGFloat(fontCount)
    
    return estimatedTotalArea < textureArea
  }
  
  fileprivate func pointSizeThatFitsForFont(_ font: UIFont, atlasRect: CGRect) -> CGFloat {
    var fittedSize = font.pointSize
    
    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize += 1
    }
    
    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize -= 1
    }
    
    return fittedSize
  }
  
  fileprivate func glyphIndices(_ ctFont: CTFont) -> [UInt16] {
    if !asciiOnly {
      let fontCount: CGGlyph = UInt16(CTFontGetGlyphCount(ctFont))
      return Array(0..<fontCount)
    }
    
    let asciiGlyphs = UnsafeMutablePointer<UniChar>.allocate(capacity: 128)
    defer { asciiGlyphs.deinitialize(count: 128); asciiGlyphs.deallocate(capacity: 128) }
    
    for i in (0...127) {
      asciiGlyphs[i] = UniChar(i)
    }
    
    var glyphIndices = UnsafeMutablePointer<CGGlyph>.allocate(capacity: 128)
    defer { glyphIndices.deinitialize(count: 128); glyphIndices.deallocate(capacity: 128) }
    CTFontGetGlyphsForCharacters(ctFont, asciiGlyphs, glyphIndices, 128)
    
    return (0...127).map {
      glyphIndices[$0]
    }.filter {
      $0 != 0
    }
  }
  
  func createAtlasForFont(_ font: UIFont, _ width: Int, _ height: Int) -> (UnsafeMutablePointer<UInt8>, dataSize: Int) {
    let dataSize = width * height
    let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)
    
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
    
    let context = CGContext(data: imageData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width), space: colorSpace, bitmapInfo: bitmapInfo)
    context?.setAllowsAntialiasing(false)
    context?.translateBy(x: 0, y: CGFloat(height))
    context?.scaleBy(x: 1, y: -1)
    context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    let atlasRect = CGRect(x: 0.0, y: 0.0, width: Double(width), height: Double(height))
    
    context?.fill(atlasRect)
    
    let fontPointSize = self.pointSizeThatFitsForFont(font, atlasRect: atlasRect) //property
    let ctFont = CTFontCreateWithName(font.fontName as CFString?, fontPointSize, nil)
    let parentFont = UIFont(name: font.fontName, size: fontPointSize) //property
    
    //let fontCount: CGGlyph = UInt16(CTFontGetGlyphCount(ctFont))
    let margin = self.estimateLineWidth(font)

    context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)

    //can probably just return this maybe
    glyphDescriptors.removeAll()
    
    let fontAscent = CTFontGetAscent(ctFont)
    let fontDescent = CTFontGetDescent(ctFont)
    
    var origin = CGPoint(x: 0, y: fontAscent)
    var maxYCoordForLine: CGFloat = -1.0
    
    //TODO: refactor this
    glyphIndices(ctFont).forEach { glyph in //look into this bug in swift-mode need parens around this for smie, .forEach is worse
      var rect = UnsafeMutablePointer<CGRect>.allocate(capacity: 1)
      defer { rect.deinitialize(); rect.deallocate(capacity: 1) }
      
      let unsafeGlyph = UnsafeMutablePointer<CGGlyph>.allocate(capacity: 1)
      defer { unsafeGlyph.deinitialize(); unsafeGlyph.deallocate(capacity: 1) }
      unsafeGlyph[0] = glyph
      
      CTFontGetBoundingRectsForGlyphs(ctFont, .horizontal, unsafeGlyph, rect, 1)
      
      if origin.x + rect.pointee.maxX + margin > CGFloat(width) {
        origin.x = 0
        origin.y = maxYCoordForLine + margin + fontDescent
      }
      
      if origin.y + rect.pointee.maxY > maxYCoordForLine {
        maxYCoordForLine = origin.y + rect.pointee.maxY
      }
      
      let glyphOriginX = origin.x - rect.pointee.origin.x + (margin * 0.5)
      let glyphOriginY = origin.y + (margin * 0.5)
      
      var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: glyphOriginX, ty: glyphOriginY)
      var unsafeTransform = UnsafeMutablePointer<CGAffineTransform>.allocate(capacity: 1)
      defer { unsafeTransform.deinitialize(); unsafeTransform.deallocate(capacity: 1) }
      unsafeTransform[0] = transform
      
      let path = CTFontCreatePathForGlyph(ctFont, glyph, unsafeTransform)
      context?.addPath(path!)
      context?.fillPath()
      
      var pathBoundingRect = path?.boundingBoxOfPath
      if (pathBoundingRect?.equalTo(CGRect.null))! {
        pathBoundingRect = CGRect.zero
      }
      
      let texCoordLeft = (pathBoundingRect?.origin.x)! / CGFloat(width)
      let texCoordRight = ((pathBoundingRect?.origin.x)! + (pathBoundingRect?.size.width)!) / CGFloat(width)
      let texCoordTop = (pathBoundingRect?.origin.y)! / CGFloat(height)
      let texCoordBottom = ((pathBoundingRect?.origin.y)! + (pathBoundingRect?.size.height)!) / CGFloat(height)
      
      let topLeftTexCoord = CGPoint(x: texCoordLeft, y: texCoordTop)
      let bottomRightTexCoord = CGPoint(x: texCoordRight, y: texCoordBottom)
      let descriptor = GlyphDescriptor(glyphIndex: glyph, topLeftTexCoord: topLeftTexCoord, bottomRightTexCoord: bottomRightTexCoord)
      glyphDescriptors.append(descriptor)
      
      origin.x += rect.pointee.width + margin
    }
    
    #if DEBUG
      if let context = context {
        debugImage = UIImage(cgImage: context.makeImage()!)
      }
      else {
        assert(false, "Failed to create debug image for font atlas.")
      }
    #endif
    
    //maybe return [Int] instead of this pointer
    //requires another transform but might not be a big deal?
    return (imageData, dataSize)
  }

  fileprivate func computeSignedDistanceFields(_ imageData: UnsafeMutablePointer<UInt8>, _ width: Int, _ height: Int) -> FlatArray<Float> {
    let ihypot = { (x: Int,  y: Int) -> Float in
      return hypot(Float(x), Float(y))
    }
    
    let distances = FlatArray(count: width * height, repeatedValue: ihypot(width, height), width: width)
    let boundaryPoints = FlatArray(count: width * height, repeatedValue: (x: 0, y: 0), width: width)
    
    let inside = { (x: Int, y: Int) -> Bool in
      return imageData[y * width + x] > UInt8(Int8.max)
    }

    (1..<height - 1).forEach { y in
      (1..<width - 1).forEach { x in
        let isInside = inside(x, y)
        if inside(x - 1, y) != isInside ||
           inside(x + 1, y) != isInside ||
           inside(x, y + 1) != isInside ||
           inside(x, y - 1) != isInside
        {
          distances[x, y] = 0
          boundaryPoints[x, y] = (x, y)
        }
      }
    }

    let distDiag: Float = sqrt(2.0)
    (1..<height - 2).forEach { y in
      (1..<width - 2).forEach { x in
        let distance = distances[x, y]
        let newDistance = ihypot(x - boundaryPoints[x, y].x, y - boundaryPoints[x, y].y)
        
        if distances[y - 1, x - 1] + distDiag < distance {
          boundaryPoints[x, y] = boundaryPoints[x - 1, y - 1]
          distances[x, y] = newDistance
        }
        
        if distances[x, y - 1] + 1.0 < distance {
          boundaryPoints[x, y] = boundaryPoints[x, y - 1]
          distances[x, y] = newDistance
        }
        
        if distances[x + 1, y - 1] + distDiag < distance {
          boundaryPoints[x, y] = boundaryPoints[x + 1, y - 1]
          distances[x, y] = newDistance
        }
        
        if distances[x - 1, y] + 1.0 < distance {
          boundaryPoints[x, y] = boundaryPoints[x - 1, y]
          distances[x, y] = newDistance
        }
      }
    }
    
    (1...height - 2).reversed().forEach { y in
      (1...width - 2).reversed().forEach { x in
        let newDistance = ihypot(x - boundaryPoints[x, y].x, y - boundaryPoints[x, y].y)
        
        if distances[x + 1, y] + 1.0 < distances[x, y] {
          boundaryPoints[x, y] = boundaryPoints[x + 1, y]
          distances[x, y] = newDistance
        }
        
        if distances[x - 1, y + 1] + distDiag < distances[x, y] {
          boundaryPoints[x, y] = boundaryPoints[x - 1, y + 1]
          distances[x, y] = newDistance
        }
        
        if distances[x, y + 1] + 1.0 < distances[x, y] {
          boundaryPoints[x, y] = boundaryPoints[x, y + 1]
          distances[x, y] = newDistance
        }
        
        if distances[x + 1, y + 1] + distDiag < distances[x, y] {
          boundaryPoints[x , y] = boundaryPoints[x + 1, y + 1]
          distances[x, y] = newDistance
        }
      }
    }
    
    (0..<height).forEach { y in
      (0..<width).forEach { x in
        if !inside(x, y) {
          distances[x, y] = -1.0 * distances[x, y]
        }
      }
    }

    return distances
  }

  fileprivate func createResampledData(_ distances: FlatArray<Float>, _ width: Int, _ height: Int, scaleFactor: Int) -> FlatArray<Float> {
    assert(width % scaleFactor == 0 && height % scaleFactor == 0)

    let scaledWidth = width / scaleFactor
    let scaledHeight = height / scaleFactor

    let scaledData: FlatArray<Float> = FlatArray(count: scaledWidth * scaledHeight, repeatedValue: 0.0, width: scaledWidth)

    stride(from: 0, to: height, by: scaleFactor).forEach { y in
      stride(from: 0, to: width, by: scaleFactor).forEach { x in
        var accum: Float = 0.0
        (0..<scaleFactor).forEach { yy in
          (0..<scaleFactor).forEach { xx in
            accum += distances[x + xx, y + yy]
          }
        }

        accum /= Float(scaleFactor * scaleFactor)

        scaledData[x / scaleFactor, y / scaleFactor] = accum
      }
    }

    return scaledData
  }

  fileprivate func createQuantizedDistanceField(_ distances: FlatArray<Float>, _ width: Int, _ height: Int, normalizationFactor: Float) -> UnsafeMutablePointer<UInt8> {
    let quanitized = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height)

    (0..<height).forEach { y in
      (0..<width).forEach { x in
        let dist = distances[x, y]
        let clampDist = max(-1 * normalizationFactor, min(dist, normalizationFactor))
        let scaledDist = clampDist / normalizationFactor
        quanitized[y * width + x] = UInt8(((scaledDist + 1) / 2) * Float(UInt8.max))
      }
    }

    return quanitized
  }

  fileprivate func createTextureData() {
    let width = asciiOnly ? Constants.AsciiHeight : Constants.AtlasSizeHeightMax
    let height = asciiOnly ? Constants.AsciiWidth : Constants.AtlasSizeHeightMax

    let (atlasData, dataSize) = createAtlasForFont(font, width, height)
    defer { atlasData.deinitialize(count: dataSize); atlasData.deallocate(capacity: dataSize) }

    let distanceFields = computeSignedDistanceFields(atlasData, width, height)

    let scaleFactor = width / textureSize
    let scaledFields = createResampledData(distanceFields, width, height, scaleFactor: scaleFactor)

    let spread = Float(estimateLineWidth(font) * 0.5)
    let textureArray = createQuantizedDistanceField(scaledFields, textureSize, textureSize, normalizationFactor: spread)

    let byteCount = textureSize * textureSize
    textureData = Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(textureArray), count: byteCount, deallocator: .free) //do I free textureArray?

    #if DEBUG
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue
    if let context = CGContext(data: textureArray, width: Int(textureSize), height: Int(textureSize), bitsPerComponent: 8, bytesPerRow: Int(textureSize), space: colorSpace, bitmapInfo: bitmapInfo) {
      debugImage = UIImage(cgImage: context.makeImage()!)
    }
    else {
      assert(false, "Failed to create debug image for font atlas.")
    }
    #endif
  }
}
