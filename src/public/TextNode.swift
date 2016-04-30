//
//  Font.swift
//  GameEngine
//
//  Created by Anthony Green on 2/15/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

//TODO: check if those casts ever get fixed

import CoreText
import Foundation
import Metal
import UIKit

/**
 A `TextNode` creates a "string" sprite essentially. 
 
 This still needs to be updated for modifying the text properties such as alignment. As well as support for glowing/outlined/better anti-aliased stuff, probably.

 - note: It also currently does not support being updated even if the text property is. I'm not sure if that will ever change or if I'll make the text property private at some point.

 - warning: This will be incredibly slow in debug mode. I'm still trying to figure out a work around. Generally, creating the `FontAtlas` using `Fonts` 
            in release mode will speed up the process significantly. After which switching back to debug will be ok as it'll be cached.
 
 - seealso: `FontAtlas` and `Fonts` classes.
 */
public class TextNode: Node, Renderable {
  private typealias GlyphClosure = (glyph: CGGlyph, bounds: CGRect) -> ()

  var text: String
  let fontAtlas: FontAtlas
  public var color = UIColor.whiteColor()

  public var texture: Texture?
  public let vertexBuffer: MTLBuffer
  public let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  /**
   Create a new text label node with a given font.
   
   - warning: If the font does not exist yet this will take forever in debug mode and a bit of time with more compiler optimizations turned on.

   - parameter text:  The string to be displayed.
   - parameter font:  The font to render the string as.
   - parameter color: The color of the node.

   - returns: A new instance of `TextNode`.
   */
  public init(text: String, font: UIFont, color: UIColor) {
    self.text = text
    self.fontAtlas = Fonts.cache.fontForUIFont(font)!
    self.color = color

    let quads = TextNode.makeTextQuads(text, fontAtlas: fontAtlas)
    self.texture = TextNode.loadTexture(fontAtlas, device: Device.shared.device)

    let (vertexBuffer, indexBuffer) = TextNode.setupBuffers(quads, device: Device.shared.device)
    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer

    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize: sizeof(Uniforms))

    super.init(size: texture!.size)
  }

  static func loadTexture(fontAtlas: FontAtlas, device: MTLDevice) -> Texture {
    let texDesc = MTLTextureDescriptor()
    let textureSize = fontAtlas.textureSize
    texDesc.pixelFormat = .R8Unorm
    texDesc.width = textureSize
    texDesc.height = textureSize
    let texture = device.newTextureWithDescriptor(texDesc)

    let region = MTLRegionMake2D(0, 0, textureSize, textureSize)
    texture.replaceRegion(region, mipmapLevel: 0, withBytes: fontAtlas.textureData.bytes, bytesPerRow: textureSize)

    return Texture(texture: texture)
  }

  //need a size that fits rect sort of thing for the text
  static func makeTextQuads(text: String, fontAtlas: FontAtlas) -> Quads {
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

    var rects = Quads()
    enumerateGlyphsInFrame(frame) { glyph, glyphBounds in
      //TODO: this probably needs to change to a dictionary because I'm not pulling out all the values
      //let glyphInfo = self.fontAtlas.glyphDescriptors[Int(glyph)]
      let tmpGlyphs = fontAtlas.glyphDescriptors.filter {
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

      let ll = SpriteVertex(s: minS, t: maxT, x: minX, y: minY)
      let ul = SpriteVertex(s: minS, t: minT, x: minX, y: maxY)
      let ur = SpriteVertex(s: maxS, t: minT, x: maxX, y: maxY)
      let lr = SpriteVertex(s: maxS, t: maxT, x: maxX, y: minY)
      rects += [Quad(ll: ll, ul: ul, ur: ur, lr: lr)]
    }

    return rects
  }

  private static func enumerateGlyphsInFrame(frame: CTFrameRef, closure: GlyphClosure) {
    let entire = CFRangeMake(0, 0)

    let framePath = CTFrameGetPath(frame)
    let frameBoundingRect = CGPathGetPathBoundingBox(framePath)

    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
    let originBuffer = UnsafeMutablePointer<CGPoint>.alloc(lines.count)
    defer { originBuffer.destroy(lines.count); originBuffer.dealloc(lines.count) }
    CTFrameGetLineOrigins(frame, entire, originBuffer)

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
          closure(glyph: glyph, bounds: glyphRect)
        }
      }
    }
    UIGraphicsEndImageContext()
  }
}

extension TextNode {
  public func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?) {
    assert(texture != nil, "A TextNode without a texture makes no sense really.")

    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
  
    let parentMatrix = parent?.modelMatrix ?? Mat4.identity
  
    let uniforms = Uniforms(projection: camera!.projection, view: camera!.view, model: decompose(parentMatrix), color: color.vec4)
  
    let offset = uniformBufferQueue.next(commandBuffer, uniforms: uniforms)
    renderEncoder.setVertexBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    renderEncoder.setFragmentBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 0)
  
    renderEncoder.setFragmentTexture(texture!.texture, atIndex: 0)
    renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)

    renderEncoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}