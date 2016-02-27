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
  init?(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String)
  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes)
}

extension Pipeline {
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

  private func createRenderEncoder(commandBuffer: MTLCommandBuffer, label: String, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState, depthState: MTLDepthStencilState) -> MTLRenderCommandEncoder {
    let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
    renderEncoder.label = label
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthState)
    
    return renderEncoder
  }
}

final class PipelineFactory {
  struct ShaderPrograms {
    static let ColorVertex = "colorVertex"
    static let ColorFragment = "colorFragment"
    static let SpriteVertex = "spriteVertex"
    static let SpriteFragment = "spriteFragment"
    static let TextVertex = "textVertex"
    static let TextFragment = "textFragment"
  }

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

  //TODO: look up below
  //not sure what happens if there is an error I haven't seen one
  func provideColorPipeline(vertexProgram: String, fragmentProgram: String) -> ColorPipeline {
    return ColorPipeline(device: device, depthState: depthState, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }

  func provideSpritePipeline(vertexProgram: String, fragmentProgram: String) -> SpritePipeline {
    return SpritePipeline(device: device, depthState: depthState, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }

  func provideTextPipeline(vertexProgram: String, fragmentProgram: String) -> TextPipeline {
    return TextPipeline(device: device, depthState: depthState, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }
}

final class ColorPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let depthState: MTLDepthStencilState

  init?(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String) {
    self.depthState = depthState
    
    let pipelineStateDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
    }
    catch let error {
      print("OH NO! Failed to create pipeline state, error \(error)")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "color encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: self.pipelineState, depthState: depthState)

    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder)
    }

    renderEncoder.endEncoding()
  }
}

final class SpritePipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let sampler: MTLSamplerState
  let depthState: MTLDepthStencilState

  init?(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String) {
    self.depthState = depthState

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Nearest
    samplerDescriptor.sAddressMode = .ClampToEdge
    samplerDescriptor.tAddressMode = .ClampToEdge
    samplerDescriptor.normalizedCoordinates = true
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    //pipelineStateDescriptor.sampleCount = view.sampleCount
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    catch let error {
      print("OH NO! Failed to create pipeline state, error \(error)")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
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

final class TextPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  let sampler: MTLSamplerState
  let depthState: MTLDepthStencilState

  init?(device: MTLDevice, depthState: MTLDepthStencilState, vertexProgram: String, fragmentProgram: String) {
    self.depthState = depthState

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Linear
    samplerDescriptor.sAddressMode = .ClampToZero
    samplerDescriptor.tAddressMode = .ClampToZero
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

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

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    catch let error {
      fatalError("\(error) text pipeline creation")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
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
