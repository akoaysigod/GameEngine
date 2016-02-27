//
//  GEPipeline.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import MetalKit

//TODO: rethink this

protocol Pipeline {
  var pipelineState: MTLRenderPipelineState! { get }

  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String)
  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: Renderables)
}

extension Pipeline {
  private var label: String {
    return "\(Self.self)"
  }
  
  private func getPrograms(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction) {
    let defaultLibrary = device.newDefaultLibrary()!
    let vertexProgram = defaultLibrary.newFunctionWithName(vertexProgram)!
    let fragmentProgram = defaultLibrary.newFunctionWithName(fragmentProgram)!
    return (vertexProgram, fragmentProgram)
  }

  private func getPipelineStateDescriptor(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> MTLRenderPipelineDescriptor {
    let (vertexProgram, fragmentProgram) = getPrograms(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    pipelineStateDescriptor.depthAttachmentPixelFormat = .Depth32Float
    
    return pipelineStateDescriptor
  }

  private func addAlphaBlendingToDescriptor(pipelineDescriptor: MTLRenderPipelineDescriptor) {
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add
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

  //TODO: look up below
  //not sure what happens if there is an error I haven't seen one
  private func createPipeline(device: MTLDevice, stateDescriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
    do {
      return try device.newRenderPipelineStateWithDescriptor(stateDescriptor)
    }
    catch let error {
      fatalError(label + ": Failed to create pipeline state, error \(error)")
    }
  }

  private func createRenderEncoder(commandBuffer: MTLCommandBuffer, label: String, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState, depthState: MTLDepthStencilState) -> MTLRenderCommandEncoder {
    let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
    renderEncoder.label = label
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthState)
    
    return renderEncoder
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

  func provideColorPipeline(vertexProgram: String, fragmentProgram: String) -> ColorPipeline {
    return ColorPipeline(device: device, depthState: depthState)
  }

  func provideSpritePipeline(vertexProgram: String, fragmentProgram: String) -> SpritePipeline {
    return SpritePipeline(device: device, depthState: depthState)
  }

  func provideTextPipeline(vertexProgram: String, fragmentProgram: String) -> TextPipeline {
    return TextPipeline(device: device, depthState: depthState)
  }
}

final class ColorPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let depthState: MTLDepthStencilState

  private struct Programs {
    static let Vertex = "colorVertex"
    static let Fragment = "colorFragment"
  }
  
  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String = Programs.Vertex, fragmentProgram: String = Programs.Fragment) {
    self.depthState = depthState
    
    let pipelineStateDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    self.pipelineState = createPipeline(device, stateDescriptor: pipelineStateDescriptor)
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: Renderables) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "color encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: self.pipelineState, depthState: depthState)

    nodes.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: nil)
    }

    renderEncoder.endEncoding()
  }
}

final class SpritePipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let sampler: MTLSamplerState
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

    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    addAlphaBlendingToDescriptor(pipelineDescriptor)
    //pipelineStateDescriptor.sampleCount = view.sampleCount

    self.pipelineState = createPipeline(device, stateDescriptor: pipelineDescriptor)
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: Renderables) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "sprite encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: self.pipelineState, depthState: depthState)
    
    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: sampler)
    }

    renderEncoder.endEncoding()
  }
}

private struct TextPrograms {
  static var Vertex = "textVertex"
  static let Fragment = "textFragment"
}

extension Pipeline {
  func encodeTwo(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: [Renderable]) {
    let z = nodes.filter { $0 is Self }
  }
}

final class TextPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let sampler: MTLSamplerState
  let depthState: MTLDepthStencilState

  init(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String = TextPrograms.Vertex, fragmentProgram: String = TextPrograms.Fragment) {
    self.depthState = depthState

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Linear
    samplerDescriptor.sAddressMode = .ClampToZero
    samplerDescriptor.tAddressMode = .ClampToZero
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    addAlphaBlendingToDescriptor(pipelineDescriptor)

    //TODO: add index buffers to everything!
    let x = 1
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .Float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    //texture stuff
    vertexDescriptor.attributes[1].format = .Float2
    vertexDescriptor.attributes[1].offset = sizeof(vector_float4)
    vertexDescriptor.attributes[1].bufferIndex = 0
    vertexDescriptor.layouts[0].stepFunction = .PerVertex
    vertexDescriptor.layouts[0].stride = sizeof(Vertex)

    //pipelineDescriptor.vertexDescriptor = vertexDescriptor

    self.pipelineState = createPipeline(device, stateDescriptor: pipelineDescriptor)
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: Renderables) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "text encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: pipelineState, depthState: depthState)

    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: sampler)
    }

    renderEncoder.endEncoding()
  }
}
