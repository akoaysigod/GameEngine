//
//  SpritePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import simd

final class SpritePipeline: RenderPipeline {
  let pipelineState: MTLRenderPipelineState
  private let sampler: MTLSamplerState?

  private struct Programs {
    static let Shader = "SpriteShaders"
    static let Vertex = "spriteVertex"
    static let Fragment = "spriteFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Nearest
    samplerDescriptor.sAddressMode = .ClampToEdge
    samplerDescriptor.tAddressMode = .ClampToEdge
    sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = SpritePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    pipelineState = SpritePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension SpritePipeline {
  func encode(encoder: MTLRenderCommandEncoder, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [SpriteNode], lights: [LightNode]?) {
    guard let node = nodes.first,
          let texture = node.texture else { return }
    guard let lights = lights,
          let light = lights.first else { return }

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)
    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 1)

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture.texture, atIndex: 0)
    encoder.setFragmentTexture(texture.lightMapTexture, atIndex: 1)

    var lightUniforms = LightUniforms(ambientColor: light.ambientColor.vec3, resolution: light.resolution.vec2, lightCount: lights.count)
    encoder.setFragmentBytes(&lightUniforms, length: strideof(LightUniforms), atIndex: 0)
    var lightData = [light.lightData]
    encoder.setFragmentBytes(&lightData, length: strideof(LightData) * lights.count, atIndex: 1)

    encoder.drawIndexedPrimitives(.Triangle,
                                  indexCount: 6 * nodes.count,
                                  indexType: .UInt16,
                                  indexBuffer: indexBuffer.buffer,
                                  indexBufferOffset: 0)
  }
}
