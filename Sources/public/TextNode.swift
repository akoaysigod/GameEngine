//
//  Font.swift
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

//TODO: check if those casts ever get fixed

import CoreText
import Metal
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

/**
 A `TextNode` creates a "string" sprite essentially. 
 
 This still needs to be updated for modifying the text properties such as alignment. As well as support for glowing/outlined/better anti-aliased stuff, probably.

 - note: It also currently does not support being updated even if the text property is. I'm not sure if that will ever change or if I'll make the text property private at some point.

 - warning: This will be incredibly slow in debug mode. I'm still trying to figure out a work around. Generally, creating the `FontAtlas` using `Fonts` 
            in release mode will speed up the process significantly. After which switching back to debug will be ok as it'll be cached.
 
 - seealso: `FontAtlas` and `Fonts` classes.
 */
open class TextNode: Node, Renderable {
  fileprivate typealias GlyphClosure = (_ glyph: CGGlyph, _ bounds: CGRect) -> ()

  open var text: String
  let fontAtlas: FontAtlas
  open var color: Color
  open var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }

  fileprivate(set) var quad: Quad

  open var texture: Texture?

  open var hidden = false
  open let isVisible = true

  /**
   Create a new text label node with a given font.
   
   - warning: If the font does not exist yet this will take forever in debug mode and a bit of time with more compiler optimizations turned on.

   - parameter text:  The string to be displayed.
   - parameter font:  The font to render the string as.
   - parameter color: The color of the node.

   - returns: A new instance of `TextNode`.
   */
  public init(text: String, font: Font, color: Color) {
    self.text = text
    self.fontAtlas = Fonts.cache.fontForUIFont(font)!
    self.color = color

    let quads = TextNode.makeTextQuads(text, color: color, fontAtlas: fontAtlas)
    quad = quads.first!

    self.texture = TextNode.loadTexture(fontAtlas, device: Device.shared.device)

    super.init(size: texture!.size)
  }

  static func loadTexture(_ fontAtlas: FontAtlas, device: MTLDevice) -> Texture {
    let texDesc = MTLTextureDescriptor()
    let textureSize = fontAtlas.textureSize
    texDesc.pixelFormat = .r8Unorm
    texDesc.width = textureSize
    texDesc.height = textureSize
    let texture = device.makeTexture(descriptor: texDesc)

    let region = MTLRegionMake2D(0, 0, textureSize, textureSize)

    fontAtlas.textureData.withUnsafeBytes { (bytes) in
      texture.replace(region: region, mipmapLevel: 0, withBytes: bytes, bytesPerRow: textureSize)
    }

    return Texture(texture: texture)
  }

  //need a size that fits rect sort of thing for the text
  static func makeTextQuads(_ text: String, color: Color, fontAtlas: FontAtlas) -> Quads {
    let rect = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0)

    let attr = [NSFontAttributeName: fontAtlas.font]
    let attrStr = NSAttributedString(string: text, attributes: attr)

    let strRng = CFRangeMake(0, attrStr.length)
    let rectPath = CGPath(rect: rect, transform: nil)
    let framesetter = CTFramesetterCreateWithAttributedString(attrStr)
    let frame = CTFramesetterCreateFrame(framesetter, strRng, rectPath, nil)

//    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
//    let frameGlyphCount = lines.reduce(0) {
//      $0 + CTLineGetGlyphCount($1)
//    }

    let rects = Quads()
    enumerateGlyphsInFrame(frame) { glyph, glyphBounds in
      //TODO: this probably needs to change to a dictionary because I'm not pulling out all the values
      //let glyphInfo = self.fontAtlas.glyphDescriptors[Int(glyph)]
      let tmpGlyphs = fontAtlas.glyphDescriptors.filter {
        return glyph == $0.glyphIndex
      }
      guard let glyphInfo = tmpGlyphs.first else { return }

      //TODO: fix this soon 
//      let minX = Float(glyphBounds.minX)
//      let maxX = Float(glyphBounds.maxX)
//      let minY = Float(glyphBounds.minY)
//      let maxY = Float(glyphBounds.maxY)
//      let minS = Float(glyphInfo.topLeftTexCoord.x)
//      let maxS = Float(glyphInfo.bottomRightTexCoord.x)
//      let minT = Float(glyphInfo.topLeftTexCoord.y)
//      let maxT = Float(glyphInfo.bottomRightTexCoord.y)

//      let ll = Vertex(s: minS, t: maxT, x: minX, y: minY)
//      let ul = Vertex(s: minS, t: minT, x: minX, y: maxY)
//      let ur = Vertex(s: maxS, t: minT, x: maxX, y: maxY)
//      let lr = Vertex(s: maxS, t: maxT, x: maxX, y: minY)
//      rects += [Quad(ll: ll, ul: ul, ur: ur, lr: lr)]
    }

    return rects
  }

  fileprivate static func enumerateGlyphsInFrame(_ frame: CTFrame, closure: @escaping GlyphClosure) {
    let entire = CFRangeMake(0, 0)

    let framePath = CTFrameGetPath(frame)
    let frameBoundingRect = framePath.boundingBoxOfPath

    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
    let originBuffer = UnsafeMutablePointer<CGPoint>.allocate(capacity: lines.count)
    defer { originBuffer.deinitialize(count: lines.count); originBuffer.deallocate(capacity: lines.count) }
    CTFrameGetLineOrigins(frame, entire, originBuffer)

    UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
    var context = UIGraphicsGetCurrentContext()
    
    for (i, line) in lines.enumerated() {
      let lineOrigin = originBuffer[i]

      let runs = CTLineGetGlyphRuns(line) as [AnyObject] as! [CTRun] //lol
      runs.forEach { run in
        let glyphCount = CTRunGetGlyphCount(run)

        let glyphBuffer = UnsafeMutablePointer<CGGlyph>.allocate(capacity: glyphCount)
        defer { glyphBuffer.deinitialize(count: glyphCount); glyphBuffer.deallocate(capacity: glyphCount) }
        CTRunGetGlyphs(run, entire, glyphBuffer)

        //TODO: probably don't need this anymore
        let positionBuffer = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
        defer { positionBuffer.deinitialize(); positionBuffer.deallocate(capacity: glyphCount) }
        CTRunGetPositions(run, entire, positionBuffer)

        (0..<glyphCount).forEach { j in
          let glyph = glyphBuffer[j]
          let glyphRect = CTRunGetImageBounds(run, context, CFRangeMake(j, 1))
          closure(glyph, glyphRect)
        }
      }
    }
    UIGraphicsEndImageContext()
  }
}
