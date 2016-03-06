//
//  GEPipeline.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import MetalKit

protocol Pipeline {
  var pipelineState: MTLRenderPipelineState { get }
  var depthState: MTLDepthStencilState { get }
  var sampler: MTLSamplerState? { get }

  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String)
  func encode<T: Renderable>(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: [T])
}

extension Pipeline {
  private var label: String {
    return "\(Self.self)"
  }
  
  private static func getPrograms(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction) {
    //default library can't be found? probably will fatalError before this as I think this means metal can't be used (or there are no metal files?)
    //either way this probably won't happen if everything else is correct
    let defaultLibrary = device.newDefaultLibrary()!
    guard let vProgram = defaultLibrary.newFunctionWithName(vertexProgram) else {
      fatalError("no vertex program for name: \(vertexProgram)")
    }
    guard let fProgram = defaultLibrary.newFunctionWithName(fragmentProgram) else {
      fatalError("no fragment program for name: \(fragmentProgram)")
    }
    return (vProgram, fProgram)
  }

  private static func createPipelineDescriptor(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> MTLRenderPipelineDescriptor {
    let (vertexProgram, fragmentProgram) = getPrograms(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    pipelineDescriptor.depthAttachmentPixelFormat = .Depth32Float

    //alpha testing
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add
    
    return pipelineDescriptor
  }

  //TODO: look up below
  //not sure what happens if there is an error I haven't seen one
  private static func createPipelineState(device: MTLDevice, descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
    do {
      return try device.newRenderPipelineStateWithDescriptor(descriptor)
    }
    catch let error {
      fatalError("\(Self.self): Failed to create pipeline state, error \(error)")
    }
  }

  private func createRenderEncoder(commandBuffer: MTLCommandBuffer, label: String, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState, depthState: MTLDepthStencilState) -> MTLRenderCommandEncoder {
    let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
    renderEncoder.label = label
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthState)
    
    return renderEncoder
  }

  func filterRenderables<T: Renderable>(renderable: Renderables) -> [T]? {
    guard renderable.count > 0 else { return nil } 

    return renderable.flatMap { (r: Renderable) -> [T] in
      if let t = r as? T {
        return [t]
      }         
      return []
    }
  }

  func encode<T: Renderable>(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: [T]) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: label, renderPassDescriptor: renderPassDescriptor, pipelineState: pipelineState, depthState: depthState)

    nodes.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: sampler)
    }

    renderEncoder.endEncoding()
  }
}

final class PipelineFactory {
  let device: MTLDevice
  let depthState: MTLDepthStencilState

  init(device: MTLDevice) {
    self.device = device
    self.depthState = PipelineFactory.createDepthStencil(device)
  }

  private static func createDepthStencil(device: MTLDevice) -> MTLDepthStencilState {
    let depthStateDescriptor = MTLDepthStencilDescriptor()
    depthStateDescriptor.depthCompareFunction = .GreaterEqual
    depthStateDescriptor.depthWriteEnabled = true
    
    return device.newDepthStencilStateWithDescriptor(depthStateDescriptor)
  }

  func provideColorPipeline() -> ColorPipeline {
    return ColorPipeline(device: device, depthState: depthState)
  }

  func provideSpritePipeline() -> SpritePipeline {
    return SpritePipeline(device: device, depthState: depthState)
  }

  func provideTextPipeline() -> TextPipeline {
    return TextPipeline(device: device, depthState: depthState)
  }
}

final class ColorPipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let depthState: MTLDepthStencilState
  let sampler: MTLSamplerState? = nil

  private struct Programs {
    static let Vertex = "colorVertex"
    static let Fragment = "colorFragment"
  }
  
  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String = Programs.Vertex, fragmentProgram: String = Programs.Fragment) {
    self.depthState = depthState
    
    let pipelineDescriptor = ColorPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    self.pipelineState = ColorPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

final class SpritePipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState?
  let depthState: MTLDepthStencilState

  private struct Programs {
    static let Vertex = "spriteVertex"
    static let Fragment = "spriteFragment"
  }

  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String = Programs.Vertex, fragmentProgram: String = Programs.Fragment) {
    self.depthState = depthState

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Nearest
    samplerDescriptor.sAddressMode = .ClampToEdge
    samplerDescriptor.tAddressMode = .ClampToEdge
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = SpritePipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    //pipelineStateDescriptor.sampleCount = view.sampleCount

    self.pipelineState = SpritePipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}

final class TextPipeline: Pipeline {
  let pipelineState: MTLRenderPipelineState
  let sampler: MTLSamplerState?
  let depthState: MTLDepthStencilState

  private struct Programs {
    static var Vertex = "textVertex"
    static let Fragment = "textFragment"
  }

  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String = Programs.Vertex, fragmentProgram: String = Programs.Fragment) {
    self.depthState = depthState

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Linear
    samplerDescriptor.sAddressMode = .ClampToZero
    samplerDescriptor.tAddressMode = .ClampToZero
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = TextPipeline.createPipelineDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .Float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0

    //texture stuff
    vertexDescriptor.attributes[1].format = .Float2
    vertexDescriptor.attributes[1].offset = sizeof(vector_float4)
    vertexDescriptor.attributes[1].bufferIndex = 0

    vertexDescriptor.layouts[0].stepFunction = .PerVertex
    vertexDescriptor.layouts[0].stride = sizeof(vector_float2) * sizeof(vector_float4)

    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    self.pipelineState = TextPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!
  }
}
