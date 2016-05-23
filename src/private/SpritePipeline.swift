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

    if let vertexDescriptor = pipelineDescriptor.vertexDescriptor {
//      vertexDescriptor.attributes[3].format = .Flo;
//      vertexDescriptor.attributes[3].offset = 0;
//      vertexDescriptor.attributes[3].bufferIndex = 1;
//      vertexDescriptor.layouts[0].stepFunction = .PerVertex;
//      vertexDescriptor.layouts[0].stride = sizeof(packed_float4);
    }



    pipelineState = SpritePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!




    vBuffer = device.newBufferWithLength(1000 * (sizeof(packed_float4) + sizeof(packed_float2)), options: .CPUCacheModeDefaultCache)
    tmpBuffer = device.newBufferWithLength(1000 * sizeof(InstanceUniforms), options: .CPUCacheModeDefaultCache)
  }

  var buffers = [Int: MTLBuffer]()
  var tmpBuffer: MTLBuffer
  var vBuffer: MTLBuffer
  var vset = false

  func encode(encoder: MTLRenderCommandEncoder, nodes: [SpriteNode]) {
    guard let node = nodes.first else { return }
    guard let texture = nodes.first?.texture?.texture else { return }

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBuffer(node.vertexBuffer, offset: 0, atIndex: 0)

    encoder.setVertexBuffer(uniformBuffer.buffer, offset: 0, atIndex: 2)
//    var uniforms = Uniforms(projection: node.camera!.projection, view: node.camera!.view)
//    encoder.setVertexBytes(&uniforms, length: sizeof(Uniforms), atIndex: 2)
    //memcpy(node.uniformBufferQueue.uniformBuffer.contents(), &uniforms, sizeof(Uniforms))

    var buffer: MTLBuffer
    if let b = buffers[node.hashValue] {
      buffer = b
    }
    else {
      buffer = Device.shared.device.newBufferWithLength(sizeof(InstanceUniforms) * 200, options: .CPUCacheModeDefaultCache)
      buffers[node.hashValue] = buffer
    }

    //tmp
    for (i, node) in nodes.enumerate() {

      var instance = InstanceUniforms(model: node.model, color: node.color.vec4)
      memcpy(buffer.contents() + sizeof(InstanceUniforms) * i, &instance, sizeof(InstanceUniforms))
    }
    //encoder.setVertexBuffer(vBuffer, offset: 0, atIndex: 0)
    encoder.setVertexBuffer(buffer, offset: 0, atIndex: 1)
    //var i_n = InstanceUniforms(model: node.model, color: node.color.vec4)
    //encoder.setVertexBytes(&i_n, length: sizeof(InstanceUniforms), atIndex: 1)
    //

    encoder.setFragmentSamplerState(sampler, atIndex: 0)
    encoder.setFragmentTexture(texture, atIndex: 0)

    encoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.buffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0, instanceCount: nodes.count)
  }
}
