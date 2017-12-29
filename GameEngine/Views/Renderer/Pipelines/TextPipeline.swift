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

  fileprivate struct Programs {
    static let Shader = "TextShaders"
    static let Vertex = "textVertex"
    static let Fragment = "textFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .nearest
    samplerDescriptor.magFilter = .linear
    samplerDescriptor.sAddressMode = .clampToZero
    samplerDescriptor.tAddressMode = .clampToZero
    sampler = device.makeSamplerState(descriptor: samplerDescriptor)

    let pipelineDescriptor = TextPipeline.makePipelineDescriptor(device: device,
                                                                 vertexProgram: vertexProgram,
                                                                 fragmentProgram: fragmentProgram)

    pipelineState = TextPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension TextPipeline {
  func encode(_ encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [TextNode], lights: [LightNode]? = nil) {
    encoder.setRenderPipelineState(pipelineState)

    nodes.forEach { _ in
      //$0.draw(encoder, indexBuffer: indexBuffer.buffer, uniformBuffer: uniformBuffer.buffer, sampler: sampler)
    }
  }
}
