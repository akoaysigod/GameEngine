//
//  GEFont.swift
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

//TODO: check if those casts ever get fixed

import CoreText
import Foundation
import GLKit
import Metal
import UIKit

class GETextLabel: GERenderNode {
  private typealias GlyphClosure = (glyph: CGGlyph, glyphIndex: Int, bounds: CGRect) -> ()

  var text: String
  let fontAtlas: FontAtlas
  let color: UIColor

  let displaySize = 72 //arbitrary right now for testing

  //var vertices = Vertices()
  //var texture: MTLTexture? = nil

  init(text: String, font: UIFont, color: UIColor) {
    self.text = text
    self.fontAtlas = Fonts.cache.fontForUIFont(font)!
    self.color = color

    super.init(vertices: Vertices())
  }

  //need a size that fits rect sort of thing for the text
  func buildMesh(device: MTLDevice) {
    let rect = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0)

    let attr = [NSFontAttributeName: fontAtlas.font]
    let attrStr = NSAttributedString(string: text, attributes: attr)

    let strRng = CFRangeMake(0, attrStr.length)
    let rectPath = CGPathCreateWithRect(rect, nil)
    let framesetter = CTFramesetterCreateWithAttributedString(attrStr)
    let frame = CTFramesetterCreateFrame(framesetter, strRng, rectPath, nil)

//    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
//    let frameGlyphCount = lines.reduce(0) {
//      $0 + CTLineGetGlyphCount($1)
//    }

//    I don't know how to use these I think it's to save space on vertices
//    let indexCount = frameGlyphCount * 6
//    var indices = [UInt16]() //???
    
    var vertices = Vertices()
    enumerateGlyphsInFrame(frame) { glyph, glyphIndex, glyphBounds in
      //TODO: this probably needs to change to a dictionary because I'm not pulling out all the values
      //let glyphInfo = self.fontAtlas.glyphDescriptors[Int(glyph)]
      let tmpGlyphs = self.fontAtlas.glyphDescriptors.filter {
        return glyph == $0.glyphIndex
      }
      guard let glyphInfo = tmpGlyphs.first else { return }

      let minX = Float(CGRectGetMinX(glyphBounds))
      let maxX = Float(CGRectGetMaxX(glyphBounds))
      let minY = Float(CGRectGetMinY(glyphBounds))
      let maxY = Float(CGRectGetMaxY(glyphBounds))
      let minS = Float(glyphInfo.topLeftTexCoord.x)
      let maxS = Float(glyphInfo.bottomRightTexCoord.x)
      let minT = Float(glyphInfo.topLeftTexCoord.y)
      let maxT = Float(glyphInfo.bottomRightTexCoord.y)
      
      //bottom left triangle
      vertices += [SpriteVertex(s: minS, t: minT, x: minX, y: maxY)]
      vertices += [SpriteVertex(s: minS, t: maxT, x: minX, y: minY)]
      vertices += [SpriteVertex(s: maxS, t: maxT, x: maxX, y: minY)]
      
      //upper right triangle
      vertices += [SpriteVertex(s: maxS, t: minT, x: maxX, y: maxY)]
      vertices += [SpriteVertex(s: maxS, t: maxT, x: maxX, y: minY)]
      vertices += [SpriteVertex(s: minS, t: minT, x: minX, y: maxY)]
    }

    self.vertices = vertices

    let texDesc = MTLTextureDescriptor()
    let textureSize = fontAtlas.textureSize
    texDesc.pixelFormat = .R8Unorm
    texDesc.width = textureSize
    texDesc.height = textureSize
    texture = device.newTextureWithDescriptor(texDesc)

    let region = MTLRegionMake2D(0, 0, textureSize, textureSize)
    texture!.replaceRegion(region, mipmapLevel: 0, withBytes: fontAtlas.textureData.bytes, bytesPerRow: textureSize)
  }

  private func enumerateGlyphsInFrame(frame: CTFrameRef, closure: GlyphClosure) {
    let entire = CFRangeMake(0, 0)

    let framePath = CTFrameGetPath(frame)
    let frameBoundingRect = CGPathGetPathBoundingBox(framePath)

    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
    let originBuffer = UnsafeMutablePointer<CGPoint>.alloc(lines.count)
    defer { originBuffer.destroy(lines.count); originBuffer.dealloc(lines.count) }
    CTFrameGetLineOrigins(frame, entire, originBuffer)

    var glyphIndexInFrame = 0
    
    UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
    var context = UIGraphicsGetCurrentContext()
    
    for (i, line) in lines.enumerate() {
      let lineOrigin = originBuffer[i]

      let runs = CTLineGetGlyphRuns(line) as [AnyObject] as! [CTRun] //lol
      runs.forEach { run in
        let glyphCount = CTRunGetGlyphCount(run)

        let glyphBuffer = UnsafeMutablePointer<CGGlyph>.alloc(glyphCount)
        defer { glyphBuffer.destroy(glyphCount); glyphBuffer.dealloc(glyphCount) }
        CTRunGetGlyphs(run, entire, glyphBuffer)

        //TODO: probably don't need this anymore
        let positionBuffer = UnsafeMutablePointer<CGPoint>.alloc(glyphCount)
        defer { positionBuffer.destroy(); positionBuffer.dealloc(glyphCount) }
        CTRunGetPositions(run, entire, positionBuffer)

        (0..<glyphCount).forEach { j in
          let glyph = glyphBuffer[j]
          let glyphRect = CTRunGetImageBounds(run, context, CFRangeMake(j, 1))
          closure(glyph: glyph, glyphIndex: glyphIndexInFrame, bounds: glyphRect)

          glyphIndexInFrame += 1
        }
      }
    }
    UIGraphicsEndImageContext()
  }
}
