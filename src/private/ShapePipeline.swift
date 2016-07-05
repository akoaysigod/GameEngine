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

final class ShapePipeline: RenderPipeline {
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
  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [ShapeNode], lights: [LightNode]? = nil) {
    guard let node = nodes.first else { return }

    encoder.setRenderPipelineState(pipelineState)

    if !didSetBuffer {
      didSetBuffer = true
      vertexBuffer.update(node.quad.vertices, size: node.quad.size, bufferIndex: bufferIndex)
    }
    let (vBuffer, offset) = vertexBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(vBuffer, offset: offset, atIndex: 0)

    nodes.enumerate().forEach { (i, node) in
      instanceBuffer.update([ShapeUniforms(model: node.model, color: node.color.vec4)], size: sizeof(ShapeUniforms), bufferIndex: bufferIndex, offset: sizeof(ShapeUniforms) * i)
    }
    let (inBuffer, inOffset) = instanceBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(inBuffer, offset: inOffset, atIndex: 1)

    let (uBuffer, uOffset) = uniformBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, atIndex: 2)

    let (iBuffer, iOffset) = indexBuffer.nextBuffer(bufferIndex)
    encoder.drawIndexedPrimitives(.Triangle, indexCount: 6, indexType: .UInt16, indexBuffer: iBuffer, indexBufferOffset: iOffset, instanceCount: nodes.count)
  }
}
