//
//  TextPipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class TextPipeline: RenderPipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState?

  private struct Programs {
    static let Shader = "TextShaders"
    static let Vertex = "textVertex"
    static let Fragment = "textFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
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
  func encode(encoder: MTLRenderCommandEncoder, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [TextNode]) {
    encoder.setRenderPipelineState(pipelineState)

    nodes.forEach { _ in
      //$0.draw(encoder, indexBuffer: indexBuffer.buffer, uniformBuffer: uniformBuffer.buffer, sampler: sampler)
    }
  }
}
