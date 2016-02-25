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

  let text: String
  let fontAtlas: FontAtlas

  let displaySize = 72 //arbitrary right now for testing

  init(text: String, font: UIFont) {
    self.text = text

    self.fontAtlas = Fonts.cache.fontForUIFont(font)!

    super.init()
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

    let x = 1
    //TODO: omg fix everything
    //also leave better comments I have no idea what this means
    let texDesc = MTLTextureDescriptor()
    texDesc.pixelFormat = .R8Unorm
    texDesc.width = 512
    texDesc.height = 512
    texture = device.newTextureWithDescriptor(texDesc)

    let region = MTLRegionMake2D(0, 0, 512, 512)
    texture!.replaceRegion(region, mipmapLevel: 0, withBytes: fontAtlas.textureData.bytes, bytesPerRow: 512)
  }

  private func enumerateGlyphsInFrame(frame: CTFrameRef, closure: GlyphClosure) {
    let entire = CFRangeMake(0, 0)

    let framePath = CTFrameGetPath(frame)
    let frameBoundingRect = CGPathGetPathBoundingBox(framePath)

    let lines = CTFrameGetLines(frame) as [AnyObject] as! [CTLine] //lol
    let originBuffer = UnsafeMutablePointer<CGPoint>.alloc(lines.count)
    CTFrameGetLineOrigins(frame, entire, originBuffer)

    var glyphIndexInFrame = 0
    
    UIGraphicsBeginImageContext(CGSize(width: 0.0, height: 0.0))
    var context = UIGraphicsGetCurrentContext()
    
    for (i, line) in lines.enumerate() {
      let lineOrigin = originBuffer[i]

      let runs = CTLineGetGlyphRuns(line) as [AnyObject] as! [CTRun] //lol
      runs.forEach { run in
        let glyphCount = CTRunGetGlyphCount(run)

        let glyphBuffer = UnsafeMutablePointer<CGGlyph>.alloc(glyphCount)
        defer { glyphBuffer.destroy(); glyphBuffer.dealloc(glyphCount) }
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

  //tmp
  override func decompose(matrix: GLKMatrix4) -> GLKMatrix4 {
    let parentRotScale = GLKMatrix4GetMatrix3(matrix)
    let selfRotScale = GLKMatrix4GetMatrix3(self.modelMatrix)
    let rotScale = parentRotScale * selfRotScale
    
    let parentTranslate = GLKMatrix4GetColumn(matrix, 3)
    let selfTranslate = GLKMatrix4GetColumn(self.modelMatrix, 3)
    let translate = parentTranslate + selfTranslate
   
    let firstColumn = GLKVector4MakeWithVector3(GLKMatrix3GetColumn(rotScale, 0), translate.x)
    let secondColumn = GLKVector4MakeWithVector3(GLKMatrix3GetColumn(rotScale, 1), translate.y)
    let thirdColumn = GLKVector4MakeWithVector3(GLKMatrix3GetColumn(rotScale, 2), self.z)
    let fourthColumn = GLKVector4(v: (0.0, 0.0, 0.0, 1.0))
    
    return GLKMatrix4MakeWithRows(firstColumn, secondColumn, thirdColumn, fourthColumn)
  }
  
//tmp
  var vertexBuffer: MTLBuffer!
  var uniformBufferQueue: BufferQueue!
  var vertexCount = 0
  override func setupBuffers() {
    let vertexData = vertices.flatMap { $0.data }
    let vertexDataSize = vertexData.count * sizeofValue(vertexData[0])
    vertexBuffer = device.newBufferWithBytes(vertexData, length: vertexDataSize, options: [])
    vertexCount = vertices.count

    uniformBufferQueue = BufferQueue(device: device, dataSize: FloatSize * modelMatrix.data.count)
  }
  
  override func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
    
    var parentMatrix = GLKMatrix4Identity
    if let parent = self.getSuperParent() {
      parentMatrix = parent.modelMatrix
    }
    
    let uniformMatrix = self.camera.multiplyMatrices(self.decompose(parentMatrix))
    let offset = self.uniformBufferQueue.next(commandBuffer, data: uniformMatrix.data)
    renderEncoder.setVertexBuffer(self.uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    
    if let texture = self.texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }
    
    renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: self.vertexCount)   
  }
} 
