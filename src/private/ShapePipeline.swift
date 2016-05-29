//
//  ShapePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class ShapePipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState? = nil

  private let indexBuffer: Buffer
  private let uniformBuffer: Buffer
  private let instanceBuffer: Buffer

  private struct Programs {
    static let Shader = "ShapeShaders"
    static let Vertex = "colorVertex"
    static let Fragment = "colorFragment"
  }
  
  init(device: MTLDevice,
       indexBuffer: Buffer,
       uniformBuffer: Buffer,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    self.indexBuffer = indexBuffer
    self.uniformBuffer = uniformBuffer

    let pipelineDescriptor = ShapePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    self.pipelineState = ShapePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!

    instanceBuffer = Buffer(length: 1000 * sizeof(InstanceUniforms))
  }
}

extension ShapePipeline {
  func encode(encoder: MTLRenderCommandEncoder, nodes: [ShapeNode]) {
    guard let node = nodes.first else { return }

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBytes(node.quad.vertices, length: node.quad.size, atIndex: 0)

    nodes.enumerate().forEach { (i, node) in
      var instance = InstanceUniforms(model: node.model)
      instanceBuffer.update(&instance, size: sizeof(InstanceUniforms), offset: sizeof(InstanceUniforms) * i)
    }
    encoder.setVertexBuffer(instanceBuffer.buffer, offset: 0, atIndex: 1)

    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 2)

    encoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.buffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0, instanceCount: nodes.count)
  }
}
