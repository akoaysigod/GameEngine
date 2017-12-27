//
//  LightPipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import simd

final class LightPipeline: RenderPipeline {
  let pipelineState: MTLRenderPipelineState

  fileprivate let resolutionBuffer: Buffer

  fileprivate struct Programs {
    static let Shader = "LightShaders"
    static let Vertex = "lightVertex"
    static let Fragment = "lightFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let pipelineDescriptor = LightPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    pipelineState = LightPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!

    resolutionBuffer = Buffer(length: MemoryLayout<Vec2>.stride)
  }
}

extension LightPipeline {
  func encode(_ encoder: MTLRenderCommandEncoder, bufferIndex: Int, uniformBuffer: Buffer, lightNodes: [LightNode]) {
    guard let light = lightNodes.first else { return }

    resolutionBuffer.update([light.resolution.vec2], size: MemoryLayout<Vec2>.stride, bufferIndex: bufferIndex)

    encoder.pushDebugGroup("light encoder")

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBytes(light.verts, length: MemoryLayout<packed_float4>.stride * light.verts.count, index: 0)

//    var pos = Vec2(0.0, 0.0)
//    encoder.setVertexBytes(&pos, length: MemoryLayout<Vec2>.size, at: 1)
    let (uBuffer, uOffset) = uniformBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, index: 1)

    let (rBuffer, rOffset) = resolutionBuffer.nextBuffer(bufferIndex)
    encoder.setFragmentBuffer(rBuffer, offset: rOffset, index: 0)

    var lightData = light.lightData
    encoder.setFragmentBytes(&lightData, length: MemoryLayout<LightData>.stride * lightNodes.count, index: 1)

    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

    encoder.popDebugGroup()
  }
}
