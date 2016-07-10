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

  private struct Programs {
    static let Shader = "LightShaders"
    static let Vertex = "lightVertex"
    static let Fragment = "lightFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let pipelineDescriptor = LightPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    pipelineState = LightPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension LightPipeline {
  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, uniformBuffer: Buffer, lightNodes: [LightNode]) {
    guard let light = lightNodes.first else { return }

    encoder.pushDebugGroup("light encoder")

    encoder.setRenderPipelineState(pipelineState)

    encoder.setVertexBytes(light.verts, length: strideof(packed_float4) * light.verts.count, atIndex: 0)

    var pos = Vec2(0.0, 0.0)
    encoder.setVertexBytes(&pos, length: sizeof(Vec2), atIndex: 1)
    let (uBuffer, uOffset) = uniformBuffer.nextBuffer(bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, atIndex: 2)

    var lightUniforms = LightUniforms(resolution: light.resolution.vec2)
    encoder.setFragmentBytes(&lightUniforms, length: strideof(LightUniforms), atIndex: 0)

    var lightData = light.lightData
    encoder.setFragmentBytes(&lightData, length: strideof(LightData) * lightNodes.count, atIndex: 1)

    encoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6)

    encoder.popDebugGroup()
  }
}
