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
  var vertices: Vertices { get set }

  var vertexBuffer: MTLBuffer! { get set }
  var sharedUniformBuffer: MTLBuffer! { get set }
  var uniformBufferQueue: BufferQueue! { get set }

  //TODO: probably change this to it's own public class
  var texture: MTLTexture? { get set }

  func setupBuffers(device: MTLDevice)
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?)
}

extension Renderable {
  func setupBuffers(device: MTLDevice) {
    guard vertexBuffer == nil else { return }

    let vertexData = self.vertices.flatMap { $0.data }
    let vertexDataSize = vertexData.count * sizeofValue(vertexData[0])
    vertexBuffer = device.newBufferWithBytes(vertexData, length: vertexDataSize, options: [])

    uniformBufferQueue = BufferQueue(device: device, dataSize: FloatSize * modelMatrix.data.count)
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
    
    let parentMatrix = superParent?.modelMatrix ?? GLKMatrix4Identity

    let uniformMatrix = camera.multiplyMatrices(decompose(parentMatrix))
    let offset = uniformBufferQueue.next(commandBuffer, data: uniformMatrix.data)
    renderEncoder.setVertexBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    
    if let texture = texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }
    
    renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertices.count)   
  }
}

typealias GERenderNodes = [GERenderNode]

public class GERenderNode: GENode, Renderable {
  var device: MTLDevice!
  
  //not sure might create a texture class to handle this stuff
  var texture: MTLTexture?
  
  var vertices: Vertices 
  var vertexBuffer: MTLBuffer!
  
  var sharedUniformBuffer: MTLBuffer!
  var uniformBufferQueue: BufferQueue!
  
  public var isVisible = true
  
  init(vertices: Vertices) {
    self.vertices = vertices
  }
}
