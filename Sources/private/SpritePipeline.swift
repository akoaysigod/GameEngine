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
  fileprivate let sampler: MTLSamplerState?

  fileprivate struct Programs {
    static let Shader = "SpriteShaders"
    static let Vertex = "spriteVertex"
    static let Fragment = "spriteFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .nearest
    samplerDescriptor.magFilter = .nearest
    samplerDescriptor.sAddressMode = .clampToEdge
    samplerDescriptor.tAddressMode = .clampToEdge
    sampler = device.makeSamplerState(descriptor: samplerDescriptor)

    let pipelineDescriptor = SpritePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    pipelineDescriptor.label = "sprite pipeline"

    pipelineState = SpritePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension SpritePipeline {
  func encode(_ encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [SpriteNode], lights: [LightNode]?) {
    guard let node = nodes.first,
          let texture = node.texture else { return }

    encoder.pushDebugGroup("sprite encoder")

    encoder.setRenderPipelineState(pipelineState)

    let (vBuffer, vOffset) = vertexBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(vBuffer, offset: vOffset, at: 0)
    let (uBuffer, uOffset) = uniformBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, at: 1)

    encoder.setFragmentSamplerState(sampler, at: 0)
    encoder.setFragmentTexture(texture.texture, at: 0)
    encoder.setFragmentTexture(texture.lightMapTexture, at: 1)

    //tmp
    var lightColor = lights!.first!.ambientColor.vec4
    encoder.setFragmentBytes(&lightColor, length: MemoryLayout<Vec4>.size, at: 0)

    let (iBuffer, iOffset) = indexBuffer.nextBuffer(bufferIndex)
    encoder.drawIndexedPrimitives(type: .triangle,
                                  indexCount: 6 * nodes.count,
                                  indexType: .uint16,
                                  indexBuffer: iBuffer,
                                  indexBufferOffset: iOffset)

    encoder.popDebugGroup()
  }
}
