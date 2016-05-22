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
  let sampler: MTLSamplerState?

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



    
    tmpBuffer = device.newBufferWithLength(1000 * sizeof(InstanceUniforms), options: .CPUCacheModeDefaultCache)
  }

  var tmpBuffer: MTLBuffer

  func encode(encoder: MTLRenderCommandEncoder, nodes: [SpriteNode]) {
    guard let node = nodes.first else { return }
    guard let texture = nodes.first?.texture?.texture else { return }

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBuffer(node.vertexBuffer, offset: 0, atIndex: 0)

    var uniforms = Uniforms(projection: node.camera!.projection, view: node.camera!.view)
    encoder.setVertexBytes(&uniforms, length: sizeof(Uniforms), atIndex: 2)
    //memcpy(node.uniformBufferQueue.uniformBuffer.contents(), &uniforms, sizeof(Uniforms))

    //tmp
    for (i, node) in nodes.enumerate() {
      var instance = InstanceUniforms(model: node.model)
      memcpy(tmpBuffer.contents() + sizeof(InstanceUniforms) * i, &instance, sizeof(InstanceUniforms))
    }
    encoder.setVertexBuffer(tmpBuffer, offset: 0, atIndex: 1)
    //

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture, atIndex: 0)

    encoder.drawIndexedPrimitives(.Triangle, indexCount: node.indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: node.indexBuffer, indexBufferOffset: 0, instanceCount: nodes.count)
  }
}
