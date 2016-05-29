//
//  TextPipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class TextPipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState?

  private let indexBuffer: Buffer
  private let uniformBuffer: Buffer

  private struct Programs {
    static let Shader = "TextShaders"
    static let Vertex = "textVertex"
    static let Fragment = "textFragment"
  }

  init(device: MTLDevice,
       indexBuffer: Buffer,
       uniformBuffer: Buffer,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    self.indexBuffer = indexBuffer
    self.uniformBuffer = uniformBuffer

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Linear
    samplerDescriptor.sAddressMode = .ClampToZero
    samplerDescriptor.tAddressMode = .ClampToZero
    sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = TextPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    pipelineState = TextPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension TextPipeline {
  func encode(encoder: MTLRenderCommandEncoder, nodes: [TextNode]) {
    encoder.setRenderPipelineState(pipelineState)

    nodes.forEach { _ in
      //$0.draw(encoder, indexBuffer: indexBuffer.buffer, uniformBuffer: uniformBuffer.buffer, sampler: sampler)
    }
  }
}
