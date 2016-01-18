//
//  GERenderNode.swift
//  GameEngine
//
//  Created by Anthony Green on 1/16/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

typealias GERenderNodes = [GERenderNode]

public class GERenderNode: GENode {
  var device: MTLDevice!
  
  //not sure might create a texture class to handle this stuff
  var texture: MTLTexture?
  
  var vertices: Vertices! {
    didSet {
      self.vertexCount = self.vertices.count
    }
  }
  private var vertexCount: Int = 0
  private var vertexBuffer: MTLBuffer!
  
  private var sharedUniformBuffer: MTLBuffer!
  private var uniformBufferQueue: BufferQueue!
  
  public var isVisible = true
  
  override init() {}
  init(vertices: Vertices) {
    self.vertices = vertices
    self.vertexCount = self.vertices.count
  }
  
  func setupBuffers() {
    let vertexData = self.vertices.flatMap { $0.data }
    let vertexDataSize = vertexData.count * sizeofValue(vertexData[0])
    self.vertexBuffer = self.device.newBufferWithBytes(vertexData, length: vertexDataSize, options: [])

    self.uniformBufferQueue = BufferQueue(device: self.device, dataSize: FloatSize * self.modelMatrix.data.count)
  }
  
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
    
    var parentMatrix = GLKMatrix4Identity
    if let parent = self.getSuperParent() {
      parentMatrix = parent.modelMatrix
    }
    

    let uniformData = self.camera.multiplyMatrices(parentMatrix * self.modelMatrix).data
    let offset = self.uniformBufferQueue.next(commandBuffer, data: uniformData)
    renderEncoder.setVertexBuffer(self.uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    
    if let texture = self.texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }
    
    renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: self.vertexCount)   
  }
}