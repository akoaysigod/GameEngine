//
//  CompositionPipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class CompositionPipeline: RenderPipeline {
  let pipelineState: MTLRenderPipelineState
  fileprivate let quadBuffer: Buffer

  fileprivate struct Programs {
    static let Shader = "CompositionShaders"
    static let Vertex = "compositionVertex"
    static let Fragment = "compositionFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let pipelineDescriptor = CompositionPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    pipelineState = CompositionPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!

    quadBuffer = CompositionPipeline.createQuad()
  }

  static func createQuad() -> Buffer {
    let quadData: [Vec2] = [
      Vec2(-1.0, -1.0),
      Vec2(1.0, -1.0),
      Vec2(-1.0, 1.0),

      Vec2(1.0, -1.0),
      Vec2(1.0, 1.0),
      Vec2(-1.0, 1.0)
    ]

    let bufferSize = MemoryLayout<Vec2>.stride * quadData.count
    let buffer = Buffer(length: bufferSize, instances: 1)
    buffer.update(quadData, size: bufferSize, bufferIndex: 0)

    return buffer
  }
}

extension CompositionPipeline {
  func encode(_ encoder: MTLRenderCommandEncoder, ambientColor: Color) {
    encoder.pushDebugGroup("composition encoder")

    encoder.setRenderPipelineState(pipelineState)

    let (buffer, offset) = quadBuffer.nextBuffer(0)
    encoder.setVertexBuffer(buffer, offset: offset, at: 0)

    var color = ambientColor.vec4
    encoder.setFragmentBytes(&color, length: MemoryLayout<Vec4>.size, at: 0)

    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

    encoder.popDebugGroup()
  }
}
