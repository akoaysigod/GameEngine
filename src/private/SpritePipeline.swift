//
//  SpritePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import simd

final class SpritePipeline: Pipeline {
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


    vBuffer = device.newBufferWithLength(1600 * strideof(Vertex) * 4, options: .CPUCacheModeDefaultCache)
    iBuffer = device.newBufferWithLength(1600 * sizeof(UInt16) * 6, options: .CPUCacheModeDefaultCache)
  }

  var buffers = [Int: MTLBuffer]()
  var vBuffer: MTLBuffer
  var iBuffer: MTLBuffer
  var vset = false
}

extension SpritePipeline {
  func encode(encoder: MTLRenderCommandEncoder, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [SpriteNode]) {
    guard let node = nodes.first else { return }
    guard let texture = node.texture?.texture else { return }

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)

    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 2)

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture, atIndex: 0)

    encoder.drawIndexedPrimitives(.Triangle,
                                  indexCount: 6 * nodes.count,
                                  indexType: .UInt16,
                                  indexBuffer: indexBuffer.buffer,
                                  indexBufferOffset: 0)
  }
}