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

  private struct Programs {
    static let Shader = "ColorShaders"
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

    tmpBuffer = device.newBufferWithLength(500 * Vertex.dataSize, options: .CPUCacheModeDefaultCache)
    uBuffer = device.newBufferWithLength(500 * sizeof(InstanceUniforms), options: .CPUCacheModeDefaultCache)
  }

  var tmpBuffer: MTLBuffer
  var uBuffer: MTLBuffer
}

extension ShapePipeline {
  func encode(encoder: MTLRenderCommandEncoder, nodes: [ShapeNode]) {
    encoder.setRenderPipelineState(pipelineState)

    nodes.forEach {
      $0.draw(encoder, indexBuffer: indexBuffer.buffer, uniformBuffer: uniformBuffer.buffer, sampler: sampler)
    }
  }
}
