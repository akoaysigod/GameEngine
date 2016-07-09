//
//  LightPipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 7/9/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

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
  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, lightNodes: [LightNode]) {

    encoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 0)
  }
}
