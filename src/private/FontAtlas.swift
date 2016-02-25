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
class GlyphDescriptor: NSObject, NSCoding {
  let glyphIndex: CGGlyph
  let topLeftTexCoord: CGPoint
  let bottomRightTexCoord: CGPoint

  init(glyphIndex: CGGlyph, topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
    self.glyphIndex = glyphIndex
    self.topLeftTexCoord = topLeftTexCoord
    self.bottomRightTexCoord = bottomRightTexCoord
  }

  private struct Keys {
    static let GlyphIndex = "glyphindex"
    static let XLeftTex = "xlefttex"
    static let YLeftTex = "ylefttex"
    static let XRightTex = "xrighttex"
    static let YRightTex = "yrighttex"
  }

  required init?(coder aDecoder: NSCoder) {
    self.glyphIndex = UInt16(aDecoder.decodeIntForKey(Keys.GlyphIndex))

    let lx = aDecoder.decodeFloatForKey(Keys.XLeftTex)
    let ly = aDecoder.decodeFloatForKey(Keys.YLeftTex)
    self.topLeftTexCoord = CGPoint(x: lx, y: ly)

    let rx = aDecoder.decodeFloatForKey(Keys.XRightTex)
    let ry = aDecoder.decodeFloatForKey(Keys.YRightTex)
    self.bottomRightTexCoord = CGPoint(x: rx, y: ry)
  }

  func encodeWithCoder(coder: NSCoder) {
    coder.encodeInt(Int32(glyphIndex), forKey: Keys.GlyphIndex)
    coder.encodeFloat(Float(topLeftTexCoord.x), forKey: Keys.XLeftTex)
    coder.encodeFloat(Float(topLeftTexCoord.y), forKey: Keys.YLeftTex)
    coder.encodeFloat(Float(bottomRightTexCoord.x), forKey: Keys.XRightTex)
    coder.encodeFloat(Float(bottomRightTexCoord.y), forKey: Keys.YRightTex)
  }
}

//2d array helper used in computing distance fields below
private final class FlatArray<T> {
  var arr: [T]
  let width: Int
  
  init(count: Int, repeatedValue: T, width: Int) {
    self.arr = [T](count: count, repeatedValue: repeatedValue)
    self.width = width
  }
  
  subscript(x: Int, y: Int) -> T {
    get {
      return self.arr[y * width + x]
    }
    set {
      arr[y * width + x] = newValue
    }
  }
}

class FontAtlas: NSObject, NSCoding {
  //these probably have to be the same right now
  private struct Constants {
    static let AtlasSizeHeightMax = 4096
    static let AtlasSizeWidthMax = 4096
    static let AsciiHeight = 1024
    static let AsciiWidth = 1024
  }
  
  let font: UIFont
  let textureSize: Int
  var textureData: NSData!
  var glyphDescriptors = [GlyphDescriptor]()
  
  var debugImage: UIImage?
  
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
  private struct Keys {
    static let Font = "font"
    static let Size = "size"
    static let Spread = "spread"
    static let Width = "width"
    static let Height = "height"
    static let TextureSize = "texturesize" //this is just height or width really...
    static let TextureData = "texturedata"
  }

  required init?(coder aDecoder: NSCoder) {
    let fontName = aDecoder.decodeObjectForKey(Keys.Font) as! String
    let fontSize = aDecoder.decodeFloatForKey(Keys.Size) 
    let fontSpread = aDecoder.decodeFloatForKey(Keys.Spread)

    self.font = UIFont(name: fontName, size: CGFloat(fontSize))!

    self.textureSize = Int(aDecoder.decodeIntForKey(Keys.TextureSize))

    self.textureData = aDecoder.decodeObjectForKey(Keys.TextureData) as! NSData
    
    super.init()
  }

  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(font.fontName, forKey: Keys.Font)
    coder.encodeInt(Int32(textureSize), forKey: Keys.TextureSize)
    coder.encodeObject(textureData, forKey: Keys.TextureData)
  }
  
  private func estimateGlyphSize(font: UIFont) -> CGSize {
    let exampleStr: NSString = "123ABC"
    let exampleStrSize = exampleStr.sizeWithAttributes([NSFontAttributeName: font])
    let averageWidth = ceil(exampleStrSize.width / CGFloat(exampleStr.length))
    let maxHeight = ceil(exampleStrSize.height)
    return CGSize(width: averageWidth, height: maxHeight)
  }
  
  private func estimateLineWidth(font: UIFont) -> CGFloat {
    let estimatedWidth = ("!" as NSString).sizeWithAttributes([NSFontAttributeName: font]).width
    return ceil(estimatedWidth)
  }
  
  private func willLikelyFitInAtlasRect(font: UIFont, size: CGFloat, rect: CGRect) -> Bool {
    let textureArea = rect.size.width * rect.size.height
    let testFont = UIFont(name: font.fontName, size: size)!
    let testCTFont = CTFontCreateWithName(font.fontName, size, nil)
    let fontCount = glyphIndices(testCTFont).count//CTFontGetGlyphCount(testCTFont)
    
    let margin = self.estimateLineWidth(testFont)
    let averageSize = self.estimateGlyphSize(testFont)
    
    let estimatedTotalArea = (averageSize.width + margin) * (averageSize.height + margin) * CGFloat(fontCount)
    
    return estimatedTotalArea < textureArea
  }
  
  private func pointSizeThatFitsForFont(font: UIFont, atlasRect: CGRect) -> CGFloat {
    var fittedSize = font.pointSize
    
    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize += 1
    }
    
    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize -= 1
    }
    
    return fittedSize
  }
  
  private func glyphIndices(ctFont: CTFont) -> [UInt16] {
    if !asciiOnly {
      let fontCount: CGGlyph = UInt16(CTFontGetGlyphCount(ctFont))
      return Array(0..<fontCount)
    }
    
    let asciiGlyphs = UnsafeMutablePointer<UniChar>.alloc(128)
    defer { asciiGlyphs.destroy(); asciiGlyphs.dealloc(128) }
    
    for i in (0...127) {
      asciiGlyphs[i] = UniChar(i)
    }
    
    var glyphIndices = UnsafeMutablePointer<CGGlyph>.alloc(128)
    defer { glyphIndices.destroy(); glyphIndices.dealloc(128) }
    CTFontGetGlyphsForCharacters(ctFont, asciiGlyphs, glyphIndices, 128)
    
    return (0...127).map {
      glyphIndices[$0]
      }.filter {
        $0 != 0
    }
  }
  
  func createAtlasForFont(font: UIFont, _ width: Int, _ height: Int) -> (UnsafeMutablePointer<UInt8>, dataSize: Int) {
    let dataSize = width * height
    let imageData = UnsafeMutablePointer<UInt8>.alloc(dataSize)
    
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo.AlphaInfoMask.rawValue & CGImageAlphaInfo.None.rawValue
    
    let context = CGBitmapContextCreate(imageData, Int(width), Int(height), 8, Int(width), colorSpace, bitmapInfo)
    CGContextSetAllowsAntialiasing(context, false)
    CGContextTranslateCTM(context, 0, CGFloat(height))
    CGContextScaleCTM(context, 1, -1)
    CGContextSetRGBFillColor(context, 0, 0, 0, 1)
    
    let atlasRect = CGRect(x: 0.0, y: 0.0, width: Double(width), height: Double(height))
    
    CGContextFillRect(context, atlasRect)
    
    let fontPointSize = self.pointSizeThatFitsForFont(font, atlasRect: atlasRect) //property
    let ctFont = CTFontCreateWithName(font.fontName, fontPointSize, nil)
    let parentFont = UIFont(name: font.fontName, size: fontPointSize) //property
    
    //let fontCount: CGGlyph = UInt16(CTFontGetGlyphCount(ctFont))
    let margin = self.estimateLineWidth(font)
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1)
    
    //can probably just return this maybe
    glyphDescriptors.removeAll()
    
    let fontAscent = CTFontGetAscent(ctFont)
    let fontDescent = CTFontGetDescent(ctFont)
    
    var origin = CGPoint(x: 0, y: fontAscent)
    var maxYCoordForLine: CGFloat = -1.0
    
    //TODO: refactor this
    glyphIndices(ctFont).forEach { glyph in //look into this bug in swift-mode need parens around this for smie, .forEach is worse
      var rect = UnsafeMutablePointer<CGRect>.alloc(1)
      defer { rect.destroy(); rect.dealloc(1) }
      
      let unsafeGlyph = UnsafeMutablePointer<CGGlyph>.alloc(1)
      defer { unsafeGlyph.destroy(); unsafeGlyph.dealloc(1) }
      unsafeGlyph[0] = glyph
      
      CTFontGetBoundingRectsForGlyphs(ctFont, .Horizontal, unsafeGlyph, rect, 1)
      
      if origin.x + CGRectGetMaxX(rect.memory) + margin > CGFloat(width) {
        origin.x = 0
        origin.y = maxYCoordForLine + margin + fontDescent
      }
      
      if origin.y + CGRectGetMaxY(rect.memory) > maxYCoordForLine {
        maxYCoordForLine = origin.y + CGRectGetMaxY(rect.memory)
      }
      
      let glyphOriginX = origin.x - rect.memory.origin.x + (margin * 0.5)
      let glyphOriginY = origin.y + (margin * 0.5)
      
      var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: glyphOriginX, ty: glyphOriginY)
      var unsafeTransform = UnsafeMutablePointer<CGAffineTransform>.alloc(1)
      defer { unsafeTransform.destroy(); unsafeTransform.dealloc(1) }
      unsafeTransform[0] = transform
      
      let path = CTFontCreatePathForGlyph(ctFont, glyph, unsafeTransform)
      CGContextAddPath(context, path)
      CGContextFillPath(context)
      
      var pathBoundingRect = CGPathGetPathBoundingBox(path)
      if CGRectEqualToRect(pathBoundingRect, CGRectNull) {
        pathBoundingRect = CGRectZero
      }
      
      let texCoordLeft = pathBoundingRect.origin.x / CGFloat(width)
      let texCoordRight = (pathBoundingRect.origin.x + pathBoundingRect.size.width) / CGFloat(width)
      let texCoordTop = pathBoundingRect.origin.y / CGFloat(height)
      let texCoordBottom = (pathBoundingRect.origin.y + pathBoundingRect.size.height) / CGFloat(height)
      
      let topLeftTexCoord = CGPoint(x: texCoordLeft, y: texCoordTop)
      let bottomRightTexCoord = CGPoint(x: texCoordRight, y: texCoordBottom)
      let descriptor = GlyphDescriptor(glyphIndex: glyph, topLeftTexCoord: topLeftTexCoord, bottomRightTexCoord: bottomRightTexCoord)
      glyphDescriptors.append(descriptor)
      
      origin.x += CGRectGetWidth(rect.memory) + margin
    }
    
    #if DEBUG
      let contextImage = CGBitmapContextCreateImage(context)
      debugImage = UIImage(CGImage: contextImage!)
    #endif
    
    //maybe return [Int] instead of this pointer
    //requires another transform but might not be a big deal?
    return (imageData, dataSize)
  }

  private func computeSignedDistanceFields(imageData: UnsafeMutablePointer<UInt8>, _ width: Int, _ height: Int) -> FlatArray<Float> {
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
    
    (1...height - 2).reverse().forEach { y in
      (1...width - 2).reverse().forEach { x in
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

  private func createResampledData(distances: FlatArray<Float>, _ width: Int, _ height: Int, scaleFactor: Int) -> FlatArray<Float> {
    assert(width % scaleFactor == 0 && height % scaleFactor == 0)

    let scaledWidth = width / scaleFactor
    let scaledHeight = height / scaleFactor

    let scaledData: FlatArray<Float> = FlatArray(count: scaledWidth * scaledHeight, repeatedValue: 0.0, width: scaledWidth)

    0.stride(to: height, by: scaleFactor).forEach { y in
      0.stride(to: width, by: scaleFactor).forEach { x in
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

  private func createQuantizedDistanceField(distances: FlatArray<Float>, _ width: Int, _ height: Int, normalizationFactor: Float) -> UnsafeMutablePointer<UInt8> {
    let quanitized = UnsafeMutablePointer<UInt8>.alloc(width * height)

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

  private func createTextureData() {
    let width = asciiOnly ? Constants.AsciiHeight : Constants.AtlasSizeHeightMax
    let height = asciiOnly ? Constants.AsciiWidth : Constants.AtlasSizeHeightMax

    let (atlasData, dataSize) = createAtlasForFont(font, width, height)
    defer { atlasData.destroy(); atlasData.dealloc(dataSize) }

    let distanceFields = computeSignedDistanceFields(atlasData, width, height)

    let scaleFactor = width / textureSize
    let scaledFields = createResampledData(distanceFields, width, height, scaleFactor: scaleFactor)

    let spread = Float(estimateLineWidth(font) * 0.5)
    let textureArray = createQuantizedDistanceField(scaledFields, textureSize, textureSize, normalizationFactor: spread)

    let byteCount = textureSize * textureSize
    textureData = NSData(bytesNoCopy: textureArray, length: byteCount, freeWhenDone: true)
  }
}
