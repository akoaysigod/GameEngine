//
//  ShapePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

private struct ShapeUniforms {
  let model: Mat4
  let color: Vec4
}

final class ShapePipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState

  private var didSetBuffer = false
  private let instanceBuffer: Buffer

  private struct Programs {
    static let Shader = "ShapeShaders"
    static let Vertex = "colorVertex"
    static let Fragment = "colorFragment"
  }
  
  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {

    let pipelineDescriptor = ShapePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    self.pipelineState = ShapePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!

    instanceBuffer = Buffer(length: 1000 * sizeof(Mat4))
  }
}

extension ShapePipeline {
  func encode(encoder: MTLRenderCommandEncoder, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [ShapeNode]) {
    guard let node = nodes.first else { return }

    encoder.setRenderPipelineState(pipelineState)

    if !didSetBuffer {
      didSetBuffer = true
      vertexBuffer.update(node.quad.vertices, size: node.quad.size)
    }
    encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)

    nodes.enumerate().forEach { (i, node) in
      instanceBuffer.update([ShapeUniforms(model: node.model, color: node.color.vec4)], size: sizeof(ShapeUniforms), offset: sizeof(ShapeUniforms) * i)
    }
    encoder.setVertexBuffer(instanceBuffer.buffer, offset: 0, atIndex: 1)

    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 2)

    encoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.buffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0, instanceCount: nodes.count)
  }
}
