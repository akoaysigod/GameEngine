//
//  ShapePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class ShapePipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState? = nil

  private let indexBuffer: MTLBuffer

  private struct Programs {
    static let Shader = "ColorShaders"
    static let Vertex = "colorVertex"
    static let Fragment = "colorFragment"
  }
  
  init(device: MTLDevice,
       indexBuffer: MTLBuffer,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    self.indexBuffer = indexBuffer

    let pipelineDescriptor = ShapePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    self.pipelineState = ShapePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

extension ShapePipeline {
  func encode<T: Renderable>(encoder: MTLRenderCommandEncoder, nodes: [T]) {
    encoder.setRenderPipelineState(pipelineState)

    nodes.forEach {
      $0.draw(encoder, indexBuffer: indexBuffer, sampler: sampler)
    }
  }
}
