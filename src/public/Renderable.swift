//
//  GERenderNode.swift
//  GameEngine
//
//  Created by Anthony Green on 1/16/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

typealias Renderables = [Renderable]

protocol Renderable: GENodeGeometry, GETree {
  var vertexBuffer: MTLBuffer { get }
  var indexBuffer: MTLBuffer { get }
  var uniformBufferQueue: BufferQueue { get }

  var texture: GETexture? { get set }
  var color: UIColor { get set }

  static func setupBuffers(quads: Quads, device: MTLDevice) -> (vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer)
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?)
}

extension Renderable {
  static func setupBuffers(quads: Quads, device: MTLDevice) -> (vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer) {
    let vertexBuffer = device.newBufferWithBytes(quads.vertexData, length: quads.vertexSize, options: [])
    let indexBuffer = device.newBufferWithBytes(quads.indicesData, length: quads.indicesSize, options: [])

    return (vertexBuffer, indexBuffer)
  }

  private func decompose(matrix: GLKMatrix4) -> GLKMatrix4 {
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
  
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
    
    let parentMatrix = parent?.modelMatrix ?? GLKMatrix4Identity

    let uniformMatrix = camera.multiplyMatrices(decompose(parentMatrix))
    let uniformData = uniformMatrix.data + color.data

    let offset = uniformBufferQueue.next(commandBuffer, data: uniformData)
    renderEncoder.setVertexBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    renderEncoder.setFragmentBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 0)
    
    if let texture = texture?.texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }

    renderEncoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}

extension GENodeGeometry {
  public func updateSize() {
    guard let renderable = self as? Renderable else { return }

    let quad: Quad
    if renderable.texture == nil {
      quad = .rect(size)
    }
    else {
      quad = .spriteRect(size)
    }

    let p = renderable.vertexBuffer.contents()
    memcpy(p, [quad].vertexData, [quad].vertexSize)
  }
}