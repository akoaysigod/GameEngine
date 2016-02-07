//
//  FontAtlas.swift
//  GameEngine
//
//  Created by Anthony Green on 2/6/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import CoreText
import Foundation
import UIKit

class FontAtlas {
  private struct Constants {
    static let AtlasSize = 4096
  }
  
  let font: UIFont
  var glyphDescriptors = [GlyphDescriptor]()
  
  var debugImage: UIImage?
  
  init(font: UIFont) {
    self.font = font
    
    let test = self.createAtlasForFont(font)
  }

  func estimateGlyphSize(font: UIFont) -> CGSize {
    let exampleStr: NSString = "123ABC"
    let exampleStrSize = exampleStr.sizeWithAttributes([NSFontAttributeName: font])
    let averageWidth = ceil(exampleStrSize.width / CGFloat(exampleStr.length))
    let maxHeight = ceil(exampleStrSize.height)
    return CGSize(width: averageWidth, height: maxHeight)
  }

  func estimateLineWidth(font: UIFont) -> CGFloat {
    let estimatedWidth = ("!" as NSString).sizeWithAttributes([NSFontAttributeName: font]).width
    return ceil(estimatedWidth)
  }

  func willLikelyFitInAtlasRect(font: UIFont, size: CGFloat, rect: CGRect) -> Bool {
    let textureArea = rect.size.width * rect.size.height
    let testFont = UIFont(name: font.fontName, size: size)!
    let testCTFont = CTFontCreateWithName(font.fontName, size, nil)
    let fontCount = CTFontGetGlyphCount(testCTFont)

    let margin = self.estimateLineWidth(testFont)
    let averageSize = self.estimateGlyphSize(testFont)

    let estimatedTotalArea = (averageSize.width + margin) * (averageSize.height + margin) * CGFloat(fontCount)
    //CFRelease(testFont)???
    return estimatedTotalArea < textureArea
  }

  func pointSizeThatFitsForFont(font: UIFont, atlasRect: CGRect) -> CGFloat {
    var fittedSize = font.pointSize

    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize += 1
    }

    while self.willLikelyFitInAtlasRect(font, size: fittedSize, rect: atlasRect) {
      fittedSize -= 1
    }

    return fittedSize
  }
  
  func createAtlasForFont(font: UIFont) -> UnsafeMutablePointer<UInt8> {
    let width = CGFloat(Constants.AtlasSize)
    let height = CGFloat(Constants.AtlasSize)
    
    let imageData = UnsafeMutablePointer<UInt8>()
    
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

    let fontCount = CTFontGetGlyphCount(ctFont)
    let margin = self.estimateLineWidth(font)

    CGContextSetRGBFillColor(context, 1, 1, 1, 1)

    self.glyphDescriptors.removeAll()

    let fontAscent = CTFontGetAscent(ctFont)
    let fontDescent = CTFontGetDescent(ctFont)

    var origin = CGPoint(x: 0, y: fontAscent)
    var maxYCoordForLine: CGFloat = -1.0
    
    var glyph: CGGlyph = 0
    for _ in (0..<fontCount) { //look into this bug in swift-mode need parens around this for smie
      let rect = UnsafeMutablePointer<CGRect>.alloc(1)
      rect[0] = CGRectZero
      CTFontGetBoundingRectsForGlyphs(ctFont, .Horizontal, &glyph, rect, 1)

      if origin.x + CGRectGetMaxX(rect.memory) + margin > width {
        origin.x = 0
        origin.y = maxYCoordForLine + margin + fontDescent
      }

      if origin.y + CGRectGetMaxY(rect.memory) > maxYCoordForLine {
        maxYCoordForLine = origin.y + CGRectGetMaxY(rect.memory)
      }

      let glyphOriginX = origin.x - rect.memory.origin.x + (margin * 0.5)
      let glyphOriginY = origin.y + (margin * 0.5)

      var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: glyphOriginX, ty: glyphOriginY)

      var pathBoundingRect = CGRectZero
      //there's probably a nicer way to do this
      let _ = withUnsafeMutablePointer(&transform) { transform in
        let path = CTFontCreatePathForGlyph(ctFont, glyph, transform)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
        
        pathBoundingRect = CGPathGetPathBoundingBox(path)
        if CGRectEqualToRect(pathBoundingRect, CGRectNull) {
          pathBoundingRect = CGRectZero
        }
      }
      
      let texCoordLeft = pathBoundingRect.origin.x / width
      let texCoordRight = pathBoundingRect.origin.x + pathBoundingRect.size.width / width
      let texCoordTop = pathBoundingRect.origin.y / height
      let texCoordBottom = pathBoundingRect.origin.y + pathBoundingRect.size.height / height

      let topLeftTexCoord = CGPoint(x: texCoordLeft, y: texCoordTop)
      let bottomRightTexCoord = CGPoint(x: texCoordRight, y: texCoordBottom)
      let descriptor = GlyphDescriptor(glyphIndex: glyph, topLeftTexCoord: topLeftTexCoord, bottomRightTexCoord: bottomRightTexCoord)
      self.glyphDescriptors.append(descriptor)

      //CGPathRelease(path)

      origin.x += CGRectGetWidth(rect.memory) + margin

      glyph += 1
    }
    
    //debug testing stuff
    let contextImage = CGBitmapContextCreateImage(context)
    self.debugImage = UIImage(CGImage: contextImage!)
    

    //CFRelease(ctFont)
    //CGContextRelease(context)
    //CGColorSpaceRelease(colorSpace)
    
    return imageData
  }
}

struct GlyphDescriptor {
  let glyphIndex: CGGlyph
  let topLeftTexCoord: CGPoint
  let bottomRightTexCoord: CGPoint
}
