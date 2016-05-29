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

  private let indexBuffer: Buffer
  private let uniformBuffer: Buffer

  private struct Programs {
    static let Shader = "SpriteShaders"
    static let Vertex = "spriteVertex"
    static let Fragment = "spriteFragment"
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

  func encode(encoder: MTLRenderCommandEncoder, nodes: [SpriteNode]) {
    guard let node = nodes.first else { return }
    guard let texture = nodes.first?.texture?.texture else { return }

    encoder.setRenderPipelineState(pipelineState)

    if !vset {
      for (i, n) in nodes.enumerate() {
        memcpy(vBuffer.contents() + (i * n.quad.size), n.quad.vertices, n.quad.size)
      }
      vset = true
      let (i, c) = Quad.indices(nodes.count)
      memcpy(iBuffer.contents(), i, c)
    }
    encoder.setVertexBuffer(vBuffer, offset: 0, atIndex: 0)


    var view = node.camera!.view
    uniformBuffer.update(&view, size: sizeof(Mat4), offset: sizeof(Mat4))
    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 2)

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture, atIndex: 0)

    encoder.drawIndexedPrimitives(.Triangle, indexCount: Quad.indicesData.count * nodes.count, indexType: .UInt16, indexBuffer: iBuffer, indexBufferOffset: 0)
  }
}
