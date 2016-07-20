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
    pipelineDescriptor.label = "sprite pipeline"

    pipelineState = SpritePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension SpritePipeline {
  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [SpriteNode], lights: [LightNode]?) {
    guard let node = nodes.first,
          let texture = node.texture else { return }

    encoder.pushDebugGroup("sprite encoder")

    encoder.setRenderPipelineState(pipelineState)

    let (vBuffer, vOffset) = vertexBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(vBuffer, offset: vOffset, atIndex: 0)
    let (uBuffer, uOffset) = uniformBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, atIndex: 1)

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture.texture, atIndex: 0)
    encoder.setFragmentTexture(texture.lightMapTexture, atIndex: 1)

    //tmp
    var lightColor = lights!.first!.ambientColor.vec4
    encoder.setFragmentBytes(&lightColor, length: sizeof(Vec4), atIndex: 0)

    let (iBuffer, iOffset) = indexBuffer.nextBuffer(bufferIndex)
    encoder.drawIndexedPrimitives(.Triangle,
                                  indexCount: 6 * nodes.count,
                                  indexType: .UInt16,
                                  indexBuffer: iBuffer,
                                  indexBufferOffset: iOffset)

    encoder.popDebugGroup()
  }
}
